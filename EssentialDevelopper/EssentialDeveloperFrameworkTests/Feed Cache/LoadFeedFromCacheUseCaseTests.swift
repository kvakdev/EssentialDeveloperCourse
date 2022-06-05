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
    
    func test_init() {
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
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrieveWith([uniqueFeed().local], timestamp: fixedDate.adding(days: -7).adding(seconds: -1))
        }
    }
    
    func test_loadDeliversEmptyFeed_onEmptyCache() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrieveWith([], timestamp: fixedDate.adding(days: -7).adding(seconds: 1))
        }
    }
    
    func test_loadDeliversFeed_onLessThanSevenDaysOldCache() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        let feed = uniqueFeed()
        
        expect(sut: sut, toCompleteWith: .success([feed.model])) {
            store.completeRetrieveWith([feed.local], timestamp: fixedDate.adding(days: -7).adding(seconds: 1))
        }
    }
    
    func test_loadDeletesCache_onRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieveWith(anyNSError())
        
        XCTAssertEqual(store.savedMessages, [.retrieve, .delete])
    }
    
    func test_loadDeliversNoFeed_onSevenDaysOldCache() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        let feed = uniqueFeed()
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrieveWith([feed.local], timestamp: fixedDate.adding(days: -7))
        }
    }
    
    func test_loadDeletesCache_onMoreThanSevenDaysOldCache() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        let feed = uniqueFeed()
        
        sut.load { _ in }
        store.completeRetrieveWith([feed.local], timestamp: fixedDate.adding(days: -7).adding(seconds: -1))
        
        XCTAssertEqual(store.savedMessages, [.retrieve, .delete])
    }
    
    func test_loadDoesNotDeleteCache_onEmptyCache() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        
        sut.load { _ in }
        store.completeRetrieveWith([], timestamp: fixedDate.adding(days: -7).adding(seconds: 1) )
        
        XCTAssertEqual(store.savedMessages, [.retrieve])
    }
    
    func test_loadDeletesCache_onSevenDaysOldCache() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        
        sut.load { _ in }
        store.completeRetrieveWith([], timestamp: fixedDate.adding(days: -7))
        
        XCTAssertEqual(store.savedMessages, [.retrieve, .delete])
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
    
    private func expect(sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.Result, after action: () -> Void, file: StaticString = #file, line: UInt = #line) {

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
    
    private func uniqueFeed() -> (local: LocalFeedImage, model: FeedImage) {
        let local = LocalFeedImage(id: UUID(), url: anyURL())
        let model = FeedImage(id: local.id, description: local.description, location: local.location, imageUrl: local.url)
        
        return (local, model)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "anyDomain", code: 0)
    }
}

extension Date {
    func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
    
    func adding(seconds: TimeInterval) -> Date {
        return addingTimeInterval(seconds)
    }
}
