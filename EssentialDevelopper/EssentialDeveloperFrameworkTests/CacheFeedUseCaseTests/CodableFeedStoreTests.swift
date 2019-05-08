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
            
            try data.write(to: storeUrl, options: .atomic)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        cleanUpCache()
    }
    
    override func tearDown() {
        super.tearDown()
        
        cleanUpCache()
    }

    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        expect(sut, toRetrieve: .empty)
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_deliversTheInsertedValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let expectedResult = FeedRetrieveResult.found(feed: feed, timestamp: timestamp)
        
        insert(sut, feed: feed, timestamp: timestamp)
        
        expect(sut, toRetrieve: expectedResult)
    }
    
    func test_retrieve_deliversTheSameValues() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        let expectedResult = FeedRetrieveResult.found(feed: feed, timestamp: timestamp)
        
        insert(sut, feed: feed, timestamp: timestamp)
        
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    func test_retrieve_deliversErrorOnCurruptedData() {
        let sut = makeSUT()
        
        insertCurruptedData(url: testStoreUrl)
        
        expect(sut, toRetrieve: .failure(anyNSError()))
    }
    
    func test_retrieve_deliversLatestResults() {
        let sut = makeSUT()
        let firstFeed = uniqueImageFeed().local
        let timestamp = Date()
        
        let firstInsertionError = insert(sut, feed: firstFeed, timestamp: timestamp)
        XCTAssertNil(firstInsertionError, "expected to insert succesfully")
        
        let latestFeed = uniqueImageFeed().local
        let latestTimestamp = Date()
        let secondInsertionError = insert(sut, feed: latestFeed, timestamp: latestTimestamp)
        XCTAssertNil(secondInsertionError, "expected to insert succesfully")
        
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: latestTimestamp))
    }
    
    func test_insert_deliversSameInsertionErrorOnFailure() {
        let sut = makeSUT(url: URL(string: "http://corruptedUrl.com")!)
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        let insertionError = insert(sut, feed: feed, timestamp: timestamp)
        XCTAssertNotNil(insertionError)
    }
    
}

//MARK: - Helpers
extension CodableFeedStoreTests {
    
    private var testStoreUrl: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private func cleanUpCache() {
        try? FileManager.default.removeItem(at: testStoreUrl)
    }
    
    func makeSUT(url: URL? = nil) -> CodableFeedStore {
        return CodableFeedStore(storeUrl: url ?? testStoreUrl)
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
    
    func expect(_ sut: CodableFeedStore, toRetrieve expectedResult: FeedRetrieveResult, file: StaticString = #file, line: UInt = #line) {
        sut.retrieve(completion: { retrievedResult in
            switch (retrievedResult, expectedResult) {
                
            case (.found(let retrievedFeed, let retrievedTimestamp), .found(let expectedFeed, let expectedTimestamp)):
                XCTAssertEqual(retrievedFeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(retrievedTimestamp, expectedTimestamp, file: file, line: line)
                
            case (.empty, .empty),
                 (.failure, .failure): break
                
            default:
                XCTFail("expected \(expectedResult) got \(retrievedResult) instead file: \(file), line: \(line)", file: file, line: line)
            }
        })
    }
}
