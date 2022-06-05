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
        
        sut.load() { _,_  in }
        
        XCTAssertEqual(store.savedMessages, [.retrieve])
    }
    
    func test_loadFails_onRetrieveError() {
        let (sut, store) = makeSUT()
        let retrieveError = NSError(domain: "retrieveError", code: 0)
        let exp = expectation(description: "wait for retrieval to complete")
        var receivedError: Error?
        
        sut.load() { _, error  in
            receivedError = error
            exp.fulfill()
        }
        store.completeRetrieveWith(retrieveError)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual((receivedError as? NSError)?.domain, retrieveError.domain)
    }
    
    func test_loadDeliversEmptyFeed_onExpiredCache() {
        let (sut, store) = makeSUT()
        
        let exp = expectation(description: "wait for retrieval to complete")
        var receivedResult: [FeedImage]?
        var receivedError: Error?
        
        sut.load() { result, error in
            receivedResult = result
            receivedError = error
            exp.fulfill()
        }
        let date = Date.distantPast
        store.completeRetrieveWith([uniqueFeedImage()], timestamp: date)
        
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedResult, [])
        XCTAssertEqual((receivedError as? NSError), nil)
    }
    
    private func makeSUT(timestamp: @escaping () -> Date = Date.init) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store, timestamp: timestamp)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(store)
        
        return (sut: sut, store: store)
    }
    
    private func uniqueFeedImage() -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), url: anyURL())
    }
}
