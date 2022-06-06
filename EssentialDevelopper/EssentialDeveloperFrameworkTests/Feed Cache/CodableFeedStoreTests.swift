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
        let feed: [LocalFeedImage]
        let timestamp: Date
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
            completion(.success(feed: decoded.feed, timestamp: decoded.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.TransactionCompletion) {
        let encoder = JSONEncoder()
        let encoded = try! encoder.encode(FeedContainer(feed: feed, timestamp: timestamp))
       
        
        try! encoded.write(to: storeURL)
        completion(nil)
    }
}

class CodableFeedStoreTests: XCTestCase {
    static let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("image-feed.store")
    
    override func setUp() {
        super.setUp()
        
        try? FileManager.default.removeItem(atPath: Self.storeURL.path)
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? FileManager.default.removeItem(atPath: Self.storeURL.path)
    }
    
    func test_init() {
        let sut = makeSUT()
        let expectedResult: RetrieveResult = .empty
        let exp = expectation(description: "wait for retreive to complete")
        sut.retrieve { result in
            switch (expectedResult, result) {
            case (.empty, .empty):
                exp.fulfill()
                break
            default:
                XCTFail("expected empty result, got \(result) instead")
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_retreivingTwice_hasNoSideEffects() {
        let sut = makeSUT()
        let exp = expectation(description: "wait for retreive to complete")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    exp.fulfill()
                    break
                default:
                    XCTFail("expected empty results twice, got \(firstResult) and \(secondResult) instead")
                }
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_retreivingNonEmptyCache_returnsInsertedFeed() {
        let sut = makeSUT()
        let feed = uniqueFeed().local
        let inputTimestamp = Date()
        let exp = expectation(description: "wait for retreive to complete")
        
        sut.insert([feed], timestamp: inputTimestamp) { error in
            XCTAssertNil(error)
            
            sut.retrieve { result in
                switch result {
                case .success(let retreivedfeed, let timestamp):
                    XCTAssertEqual(retreivedfeed, [feed])
                    XCTAssertEqual(timestamp, inputTimestamp)
                    exp.fulfill()
                default:
                    XCTFail("expected \(RetrieveResult.success(feed: [feed], timestamp: inputTimestamp ))result, got \(result) instead")
                }
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_retreivingCorruptData_returnFailure() throws {
        let corruptData = Data("anyString".utf8)
        try corruptData.write(to: Self.storeURL)

        let exp = expectation(description: "wait for retreive to complete")
        let sut = makeSUT(storeURL: Self.storeURL)
        
        sut.retrieve { result in
            switch result {
            case .failure:
                exp.fulfill()
            default:
                XCTFail("Expected error got \(result) instead")
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func makeSUT(storeURL: URL = CodableFeedStoreTests.storeURL) -> CodableFeedStore {
        return CodableFeedStore(storeURL: storeURL)
    }
}
