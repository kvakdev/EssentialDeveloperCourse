//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Andre Kvashuk on 6/5/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotHaveSideEffects() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.savedMessages, [])
    }
    
    func test_validateFeed_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache() { _ in }
        store.completeRetrieveWith(anyNSError())
        
        XCTAssertEqual(store.savedMessages, [.retrieve, .delete])
    }
    
    func test_validateFeed_hasNoSideEffectsOnValidTimestamp() {
        let (sut, store) = makeSUT()
        
        sut.validateCache() { _ in }

        store.completeRetrieveWith([uniqueFeed().local], timestamp: Date().minusMaxCacheAge().adding(seconds: 1))
        
        XCTAssertEqual(store.savedMessages, [.retrieve])
    }
    
    func test_validate_deletesCacheOnExactExpirationTimestamp() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        
        sut.validateCache() { _ in }
        let expirationTimestamp = fixedDate.minusMaxCacheAge()
        store.completeRetrieveWith([], timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.savedMessages, [.retrieve, .delete])
    }
    
    func test_validate_deletesCacheOnExpiredTimestamp() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        
        sut.validateCache() { _ in }

        let expiredTimestamp = fixedDate.minusMaxCacheAge().adding(seconds: -1)
        store.completeRetrieveWith([], timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.savedMessages, [.retrieve, .delete])
    }
    
    func test_validate_doesNotDeleCacheAfterSutHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store, timestamp: { Date() })
        
        sut?.validateCache() { _ in }
        sut = nil
        store.completeRetrieveWith(anyNSError())
        XCTAssertEqual(store.savedMessages, [.retrieve])
    }
    
    func test_validate_succeedsOnRetreivalErrorAndSuccessfulDeletion() {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store, timestamp: { Date() })
        
        expect(sut, toCompleteWith: .success(())) {
            store.completeRetrieveWith(anyNSError())
            store.successfulyCompleteDeletion()
        }
    }
    
    func test_validateCache_succeedsOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        expect(sut, toCompleteWith: .success(()), when: {
            store.completeRetrieveWith([], timestamp: Date())
        })
    }
    
    private func expect(_ sut: LocalFeedLoader, toCompleteWith result: LocalFeedLoader.ValidationResult, when action: VoidClosure, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for validation to complete")
        
        sut.validateCache { receivedResult in
            switch (receivedResult, result) {
            case (.success(()), .success(())):
                break
                
            case (.failure(let receivedError), .failure(let expectedError)):
                XCTAssertEqual((receivedError as NSError), (expectedError as NSError), file: file, line: line)
                
            default:
                XCTFail("Expected to get \(result), but got \(receivedResult) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(timestamp: @escaping () -> Date = Date.init) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store, timestamp: timestamp)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(store)
        
        return (sut: sut, store: store)
    }
}
