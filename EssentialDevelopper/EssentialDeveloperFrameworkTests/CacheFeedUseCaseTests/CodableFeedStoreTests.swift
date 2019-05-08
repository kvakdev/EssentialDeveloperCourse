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
        
        do {
            let cache = try JSONDecoder().decode(FeedCache.self, from: data)
            completion(.found(feed: cache.feed, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
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
    private let testStoreUrl = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("feed-image.store")
    
    override func setUp() {
        super.setUp()
        
        cleanUpCache()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cleanUpCache()
    }
    
    private func cleanUpCache() {
        try? FileManager.default.removeItem(at: testStoreUrl)
    }
    
    func makeSUT(url: URL? = nil) -> CodableFeedStore {
        return CodableFeedStore(storeUrl: url ?? testStoreUrl)
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
        let expectedResult = FeedRetrieveResult.found(feed: feed, timestamp: timestamp)
        
        insert(sut, feed: feed, timestamp: timestamp)
        
        expect(sut, result: expectedResult)
    }
    
    func test_retrieveTwice_deliversTheSameValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let expectedResult = FeedRetrieveResult.found(feed: feed, timestamp: timestamp)
        
        insert(sut, feed: feed, timestamp: timestamp)
        
        expect(sut, result: expectedResult)
        expect(sut, result: expectedResult)
    }
    
    func test_retrieve_deliversErrorOnCurruptedData() {
        let sut = makeSUT()
        
        insertCurruptedData(url: testStoreUrl)
        
        expect(sut, result: .failure(anyNSError()))
    }
    
    func test_insert_deliversInsertionErrorOnFailure() {
        let sut = makeSUT(url: URL(string: "http://corruptedUrl.com")!)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert(sut, feed: feed, timestamp: timestamp)
        XCTAssertNotNil(insertionError)
    }
    
    @discardableResult
    func insert(_ sut: CodableFeedStore, feed: [LocalFeedImage], timestamp: Date) -> Error? {
        let exp = expectation(description: "waitin for insert to complete")
        var insertionError: Error?
        
        sut.insert(feed, timestamp: timestamp) { error in
            insertionError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return insertionError
    }
    
    func insertCurruptedData(url: URL) {
        let data = "corrupted data".data(using: .utf8)
        try! data?.write(to: url, options: .atomic)
    }
    
    func expect(_ sut: CodableFeedStore, result: FeedRetrieveResult, file: StaticString = #file, line: UInt = #line) {
        sut.retrieve(completion: { retrievedResult in
            switch (retrievedResult, result) {
                
            case (.found(let retrievedFeed, let retrievedTimestamp), .found(let expectedFeed, let expectedTimestamp)):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
                
            case (.empty, .empty),
                 (.failure, .failure): break
                
            default:
                XCTFail("expected \(result) got \(retrievedResult) instead file: \(file), line: \(line)")
            }
        })
    }
    
}
