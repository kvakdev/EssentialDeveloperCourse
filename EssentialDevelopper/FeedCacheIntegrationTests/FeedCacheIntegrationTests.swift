//
//  FeedCacheIntegrationTests.swift
//  FeedCacheIntegrationTests
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class FeedCacheIntegrationTests: XCTestCase {
    
    func test_cache_hasNoSideEffectsReadingFromAnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "wait for load to complete")
        
        sut.load { result in
            switch result {
            case .success(let feed):
                XCTAssertEqual(feed, [])
            case .failure:
                XCTFail("Load failed, expected empty feed")
            }
            
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_cache_storesTheDataOnDisk() {
        let writeSUT = makeSUT()
        let readSUT = makeSUT()
        let feed = [uniqueFeed().model]
        let writeExp = expectation(description: "wait for save to complete")
        
        writeSUT.save(feed) { result in
            writeExp.fulfill()
        }
        wait(for: [writeExp], timeout: 1.0)
        
        let readExp = expectation(description: "wait for load to complete")
        readSUT.load { result in
            switch result {
            case .success(let retreivedFeed):
                XCTAssertEqual(retreivedFeed, feed)
            case .failure:
                XCTFail("Expected result got error instead")
            }
            readExp.fulfill()
        }
        
        wait(for: [readExp], timeout: 1.0)
    }
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificaStoreURL()
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let feedStore = try! CoreDataFeedStore(bundle: bundle, storeURL: storeURL)
        let sut = LocalFeedLoader(feedStore, timestamp: { Date() })
         
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    func testSpecificaStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
