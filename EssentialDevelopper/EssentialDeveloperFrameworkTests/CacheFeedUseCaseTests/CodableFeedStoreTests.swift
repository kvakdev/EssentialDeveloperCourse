//
//  CodableFeedStore.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 5/7/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class CodableFeedStoreTests: XCTestCase, FeedStoreSpecs {
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
    
    func test_insert_overwritesLatestResults() {
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
    
    func test_delete_deliversErrorOnDeletionFailure() {
        let url = docsDirUrl
        let sut = makeSUT(url: url)
        
        let deletionError = deleteCache(sut)
        
        XCTAssertNotNil(deletionError)
    }
    
    func test_delete_removesCacheOnNonEmptyCache() {
        let sut = makeSUT()
        let feed = uniqueImageFeed().local
        let timestamp = Date()
        
        insert(sut, feed: feed, timestamp: timestamp)
        deleteCache(sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_hasNoSideEffects() {
        let sut = makeSUT()
        deleteCache(sut)
        
        expect(sut, toRetrieve: .empty)
    }
    
    func test_operations_completeSerially() {
        let sut = makeSUT()
        var operations = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            operations.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.deleteCache { _ in
            operations.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed().local, timestamp: Date()) { _ in
            operations.append(op3)
            op3.fulfill()
        }
        
        wait(for: [op1, op2, op3], timeout: 5.0)
        
        XCTAssertEqual(operations, [op1, op2, op3])
    }
}

//MARK: - Helpers
extension CodableFeedStoreTests {
    
    private var testStoreUrl: URL {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: self)).store")
    }
    
    private var docsDirUrl: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    }
    
    private func cleanUpCache() {
        try? FileManager.default.removeItem(at: testStoreUrl)
    }
    
    func makeSUT(url: URL? = nil) -> FeedStore {
        let sut = CodableFeedStore(storeUrl: url ?? testStoreUrl)
        
        trackMemoryLeaks(sut)
        
        return sut
    }
    
    @discardableResult
    func insert(_ sut: FeedStore, feed: [LocalFeedImage], timestamp: Date) -> Error? {
        let exp = expectation(description: "waitin for insert to complete")
        var insertionError: Error?
        
        sut.insert(feed, timestamp: timestamp) { error in
            insertionError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        return insertionError
    }
    
    @discardableResult
    func deleteCache(_ sut: FeedStore) -> Error? {
        let exp = expectation(description: "waiting for delete to complete")
        var capturedError: Error?
        
        sut.deleteCache { error in
            capturedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 2.0)
        
        return capturedError
    }
    
    func insertCurruptedData(url: URL) {
        let data = "corrupted data".data(using: .utf8)
        try! data?.write(to: url, options: .atomic)
    }
    
    func expect(_ sut: FeedStore, toRetrieve expectedResult: FeedRetrieveResult, file: StaticString = #file, line: UInt = #line) {
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
