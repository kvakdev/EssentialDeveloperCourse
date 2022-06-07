//
//  CodableFeedStore.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/6/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class CodableFeedStore: FeedStore {
    
    private struct FeedContainer: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
    }
    
    private struct CodableFeedImage: Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
        
        init(local: LocalFeedImage) {
            self.id = local.id
            self.description = local.description
            self.url = local.url
            self.location = local.location
        }
    }
    
    private let storeURL: URL
    
    init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    func retrieve(_ completion: @escaping FeedStore.RetrieveCompletion) {
        guard let data = try? Data(contentsOf: storeURL) else {
            return completion(.empty)
        }
        
        let decoder = JSONDecoder()
        
        do {
            let decoded = try decoder.decode(FeedContainer.self, from: data)
            completion(.success(feed: decoded.feed.map { $0.local }, timestamp: decoded.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.TransactionCompletion) {
        do {
            let encoder = JSONEncoder()
            let encoded = try! encoder.encode(FeedContainer(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
           
            try encoded.write(to: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    func deleteCachedFeed(completion: @escaping FeedStore.TransactionCompletion) {
        guard FileManager.default.fileExists(atPath: storeURL.path) else {
            return completion(nil)
        }
        
        do {
            try FileManager.default.removeItem(at: storeURL)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}

class CodableFeedStoreTests: XCTestCase {
    override func setUp() {
        super.setUp()
        
        try? removeSideEffects()
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? removeSideEffects()
    }
    
    func test_init() {
        let sut = makeSUT()

        expect(sut: sut, toRetreive: .empty)
    }
    
    func test_retreivingTwice_hasNoSideEffects() {
        let sut = makeSUT()
        
        expect(sut: sut, toRetreiveTwice: .empty)
    }
    
    func test_retreivingNonEmptyCache_returnsInsertedFeed() {
        let sut = makeSUT()
        let feed = uniqueFeed().local
        let inputTimestamp = Date()
        
        insert(sut: sut, feed: [feed], timestamp: inputTimestamp)
        expect(sut: sut, toRetreive: .success(feed: [feed], timestamp: inputTimestamp))
        expect(sut: sut, toRetreiveTwice: .success(feed: [feed], timestamp: inputTimestamp))
    }
    
    func test_inserting_overridesPreviousCache() {
        let sut = makeSUT()
        let firstFeed = uniqueFeed().local
        let firstTimestamp = Date().adding(seconds: -1)
        let secondFeed = uniqueFeed().local
        let secondTimestamp = Date()
        
        insert(sut: sut, feed: [firstFeed], timestamp: firstTimestamp)
        expect(sut: sut, toRetreive: .success(feed: [firstFeed], timestamp: firstTimestamp))
        
        insert(sut: sut, feed: [secondFeed], timestamp: secondTimestamp)
        expect(sut: sut, toRetreive: .success(feed: [secondFeed], timestamp: secondTimestamp))
    }
    
    func test_delete_returnsNoErrorOnEmptyCache() {
        let sut = makeSUT()
        
        XCTAssertNil(deleteCache(sut: sut))
    }
    
    func test_delete_removesOldCache() {
        let sut = makeSUT()
        
        insert(sut: sut, feed: [uniqueFeed().local], timestamp: Date())
        deleteCache(sut: sut)
        expect(sut: sut, toRetreive: .empty)
    }
    
    func test_delete_returnsFailureOnDeleteError() {
        let unautorizedURL = systemCacheDirectory()
        let sut = makeSUT(storeURL: unautorizedURL)
        let error = deleteCache(sut: sut)
        
        XCTAssertNotNil(error, "expected to get permission error")
    }
    
    private func systemCacheDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
    
    @discardableResult
    private func deleteCache(sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for delete to complete")
        var receivedError: Error?
        
        sut.deleteCachedFeed { error in
            receivedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    func test_retreivingCorruptData_returnsFailure() throws {
        let corruptData = Data("anyString".utf8)
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try corruptData.write(to: storeURL)
        
        expect(sut: sut, toRetreive: .failure(anyNSError()))
    }
    
    func test_retreivingCorruptDataTwice_returnsFailureTwice() throws {
        let corruptData = Data("anyString".utf8)
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try corruptData.write(to: storeURL)
        
        expect(sut: sut, toRetreiveTwice: .failure(anyNSError()))
    }
    
    func test_insert_deliversErrorIfAny() {
        let invalidURL = anyURL()
        let sut = makeSUT(storeURL: invalidURL)
        let exp = expectation(description: "wait for insert to complete")
        
        sut.insert([uniqueFeed().local], timestamp: Date()) { error in
            XCTAssertNotNil(error)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func insert(sut: FeedStore, feed: [LocalFeedImage], timestamp: Date) {
        let exp = expectation(description: "wait for retreive to complete")
        
        sut.insert(feed, timestamp: timestamp) { error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(sut: FeedStore, toRetreive expectedResult: RetrieveResult, file: StaticString = #file, line: UInt = #line) {
        let sut = makeSUT()
        let exp = expectation(description: "wait for retreive to complete")
  
        sut.retrieve { result in
            switch (result, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                exp.fulfill()
            case (.success(let retreivedfeed, let timestamp), .success(feed: let expectedFeed, let expectedTimestamp)):
                XCTAssertEqual(retreivedfeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(timestamp, expectedTimestamp, file: file, line: line)
                exp.fulfill()
            default:
                XCTFail("expected \(expectedResult) result, got \(result) instead", file: file, line: line)
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(sut: FeedStore, toRetreiveTwice result: RetrieveResult) {
        expect(sut: sut, toRetreive: result)
        expect(sut: sut, toRetreive: result)
    }
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: Self.self)).store")
    }
    
    private func removeSideEffects() throws {
        try FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
