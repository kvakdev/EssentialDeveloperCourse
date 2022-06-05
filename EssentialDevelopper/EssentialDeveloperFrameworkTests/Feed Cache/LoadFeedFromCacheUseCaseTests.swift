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
        let (sut, store) = makeSUT()
        let date = Date.distantPast
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrieveWith([uniqueFeedImage()], timestamp: date)
        }
    }
    
    private func expect(sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.Result, after action: () -> Void) {

        sut.load { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success(let expectedFeed), .success(let receivedFeed)):
                XCTAssertEqual(expectedFeed, receivedFeed)
            case (.failure(let expectedError), .failure(let receivedError)):
                XCTAssertEqual((expectedError as NSError), (receivedError as NSError))
            default:
                XCTFail("expected result \(expectedResult), got \(receivedResult) instead")
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
    
    private func uniqueFeedImage() -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), url: anyURL())
    }
}
