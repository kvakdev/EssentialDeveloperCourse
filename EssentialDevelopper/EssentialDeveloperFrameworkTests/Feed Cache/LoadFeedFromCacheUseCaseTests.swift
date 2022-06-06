//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/5/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class LoadFeedFromCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotHaveSideEffects() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.savedMessages, [])
    }
    
    func test_loadCommandTriggers_retrieveMessage() {
        let (sut, store) = makeSUT()
        
        sut.load() { _ in }
        
        XCTAssertEqual(store.savedMessages, [.retrieve])
    }
    
    func test_loadFails_onRetrieveError() {
        let (sut, store) = makeSUT()
        let retrieveError = NSError(domain: "retrieveError", code: 0)
        
        expect(sut: sut, toCompleteWith: .failure(retrieveError)) {
            store.completeRetrieveWith(retrieveError)
        }
    }
    
    func test_loadDeliversEmptyFeed_onExpiredCache() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        let expiredTimestamp = fixedDate.minusMaxCacheAge().adding(seconds: -1)
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrieveWith([uniqueFeed().local], timestamp: expiredTimestamp)
        }
    }
    
    func test_loadDeliversEmptyFeed_onEmptyCache() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrieveWith([], timestamp: fixedDate)
        }
    }
    
    func test_loadDeliversFeed_onLessThanSevenDaysOldCacheNonExpiredTimestamp() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        let feed = uniqueFeed()
        
        expect(sut: sut, toCompleteWith: .success([feed.model])) {
            store.completeRetrieveWith([feed.local], timestamp: fixedDate.minusMaxCacheAge().adding(seconds: 1))
        }
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieveWith(anyNSError())
        
        XCTAssertEqual(store.savedMessages, [.retrieve])
    }
    
    func test_loadDeliversNoFeed_onExactExpirationTimestamp() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        let feed = uniqueFeed()
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrieveWith([feed.local], timestamp: fixedDate.minusMaxCacheAge())
        }
    }
    
    func test_loadHasNoSideEffects_onExpiredTimestamp() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        let feed = uniqueFeed()
        
        sut.load { _ in }
        let expiredTimestamp = fixedDate.minusMaxCacheAge().adding(seconds: -1)
        store.completeRetrieveWith([feed.local], timestamp: expiredTimestamp)
        
        XCTAssertEqual(store.savedMessages, [.retrieve])
    }
    
    func test_loadDoesNotHaveSideEffects_onNonExpiredTimestamp() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        
        sut.load { _ in }
        let nonExpiredTimestamp = fixedDate.minusMaxCacheAge().adding(seconds: 1)
        store.completeRetrieveWith([], timestamp: nonExpiredTimestamp)
        
        XCTAssertEqual(store.savedMessages, [.retrieve])
    }
    
    func test_load_hasNoSideEffectsOnExpirationTimestamp() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        
        sut.load { _ in }
        let expirationTimestamp = fixedDate.minusMaxCacheAge()
        store.completeRetrieveWith([], timestamp: expirationTimestamp)
        
        XCTAssertEqual(store.savedMessages, [.retrieve])
    }
    
    func test_loadDoesnotDeliverResult_afterSUTHasBeenDeallocated() {
        let store = FeedStoreSpy()
        let date = Date()
        var sut: LocalFeedLoader? = LocalFeedLoader(store, timestamp: { date })
        var receivedResults: [FeedLoaderResult] = []
        sut?.load({ result in
            receivedResults.append(result)
        })
        
        sut = nil
        store.completeRetrieveWith([uniqueFeed().local], timestamp: date)
        
        XCTAssertEqual(receivedResults, [])
    }
    
    private func expect(sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadResult, after action: () -> Void, file: StaticString = #file, line: UInt = #line) {

        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success(let expectedFeed), .success(let receivedFeed)):
                XCTAssertEqual(expectedFeed, receivedFeed, file: file, line: line)
            case (.failure(let expectedError), .failure(let receivedError)):
                XCTAssertEqual((expectedError as NSError), (receivedError as NSError), file: file, line: line)
            default:
                XCTFail("expected result \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
        }
        
        action()
    }
    
    private func makeSUT(timestamp: @escaping () -> Date = Date.init) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store, timestamp: timestamp)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(store)
        
        return (sut: sut, store: store)
    }
}
