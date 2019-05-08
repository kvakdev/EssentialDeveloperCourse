//
//  CodableFeedStore.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 5/7/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class CodableFeedStore {
    private struct FeedCache: Codable {
        let feed: [LocalFeedImage]
        let timestamp: Date
    }
    private let storeUrl: URL
    
    init(storeUrl: URL) {
        self.storeUrl = storeUrl
    }
    
    func retrieve(completion: @escaping (FeedRetrieveResult) -> Swift.Void) {
        
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.empty)
        }
        let cache = try! JSONDecoder().decode(FeedCache.self, from: data)
        completion(.found(feed: cache.feed, timestamp: cache.timestamp))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCallback) {
        do {
            let encoder = JSONEncoder()
            let cache = FeedCache(feed: feed, timestamp: timestamp)
            let data = try encoder.encode(cache)
            
            try data.write(to: storeUrl)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

class CodableFeedStoreTests: XCTestCase {
    private let storeUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("feed-image.store")
    
    override func setUp() {
        super.setUp()
        
        cleanUpCache()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cleanUpCache()
    }
    
    private func cleanUpCache() {
        try? FileManager.default.removeItem(at: storeUrl)
    }
    
    func makeSUT() -> CodableFeedStore {
        return CodableFeedStore(storeUrl: storeUrl)
    }
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "waiting for retrieve to complete")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("expected empty got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let exp = expectation(description: "waiting for retrieve to complete")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult){
                case (.empty, .empty):
                    break
                default:
                    XCTFail("expected empty got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieveAfterInsertion_deliversTheSameValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        sut.insert(feed, timestamp: timestamp) { error in
            XCTAssertNil(error)
            
            sut.retrieve(completion: { result in
                switch result {
                case .found(let retrievedFeed, let retrievedTimestamp):
                    XCTAssertEqual(retrievedFeed, feed)
                    XCTAssertEqual(retrievedTimestamp, timestamp)
                default:
                    XCTFail("expected success with \(feed) and \(timestamp) got \(result) instead")
                }
            })
        }
    }
    
    
}
