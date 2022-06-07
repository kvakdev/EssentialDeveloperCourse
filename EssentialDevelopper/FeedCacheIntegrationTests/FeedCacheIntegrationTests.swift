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
    
    override func setUp() {
        super.setUp()
        
        removeSideEffects()
    }
    
    override func tearDown() {
        super.tearDown()
        
        removeSideEffects()
    }
    
    private func removeSideEffects() {
        try? FileManager.default.removeItem(at: testSpecificaStoreURL())
    }
    
    func test_cache_hasNoSideEffectsReadingFromAnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toLoad: .success([]))
    }
    
    func test_cache_storesTheDataOnDisk() {
        let writeSUT = makeSUT()
        let readSUT = makeSUT()
        let feed = [uniqueFeed().model]
  
        expect(writeSUT, toSave: feed)
        expect(readSUT, toLoad: .success(feed))
    }
    
    private func expect(_ sut: LocalFeedLoader, toSave feed: [FeedImage]) {
        let exp = expectation(description: "wait for save to complete")
        
        sut.save(feed) { result in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedResult: FeedLoaderResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load to complete")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let retreivedFeed), .success(let expectedFeed)):
                XCTAssertEqual(retreivedFeed, expectedFeed, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("expected \(expectedResult), got \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
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
