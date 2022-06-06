//
//  CodableFeedStore.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/6/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class CodableFeedStore {
    
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
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(FeedContainer(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
       
        
        try! encoded.write(to: storeURL)
        completion(nil)
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
    }
    
    func test_retreivingCorruptData_returnFailure() throws {
        let corruptData = Data("anyString".utf8)
        try corruptData.write(to: testSpecificStoreURL())

        let sut = makeSUT()
        
        expect(sut: sut, toRetreive: .failure(anyNSError()))
    }
    
    private func insert(sut: CodableFeedStore, feed: [LocalFeedImage], timestamp: Date) {
        let exp = expectation(description: "wait for retreive to complete")
        
        sut.insert(feed, timestamp: timestamp) { error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(sut: CodableFeedStore, toRetreive expectedResult: RetrieveResult, file: StaticString = #file, line: UInt = #line) {
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
                XCTFail("expected \(expectedResult)) result, got \(result) instead", file: file, line: line)
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(sut: CodableFeedStore, toRetreiveTwice result: RetrieveResult) {
        expect(sut: sut, toRetreive: result)
        expect(sut: sut, toRetreive: result)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CodableFeedStore {
        let sut = CodableFeedStore(storeURL: testSpecificStoreURL())
        
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
