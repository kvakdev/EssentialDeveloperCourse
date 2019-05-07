//
//  ValidateCachedFeedUseCaseTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 5/7/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class ValidateCachedFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotHaveSideEffects() {
        let (store, _) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_validate_deletesCacheOnRetrievalError() {
        let (store, sut) = makeSUT()
        
        sut.validateCache()
        
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .delete])
    }
    
    func test_validate_deletesCacheOnExpiredDate() {
        let timestamp = Date()
        let expiredDate = timestamp.minusMaxAge().addingSeconds(-1)
        let (store, sut) = makeSUT(timestamp: { timestamp })
        let feed = uniqueImageFeed()
        
        sut.validateCache()
        
        store.completeRetrieveSuccessfully(result: ( feed.local, expiredDate ))
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .delete])
    }
    
    func test_validate_deletesCacheOnExpirationDate() {
        let fixedDate = Date()
        let (store, sut) = makeSUT(timestamp: { fixedDate })
        let feed = uniqueImageFeed()
        let expirationDate = fixedDate.minusMaxAge()
        
        sut.validateCache()
        store.completeRetrieveSuccessfully(result: (feed.local, expirationDate))
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .delete])
    }
    
    func test_validate_doesNotDeleteNonExpiredCache() {
        let fixedDate = Date()
        let (store, sut) = makeSUT(timestamp: { fixedDate })
        let feed = uniqueImageFeed()
        let nonExpiredDate = fixedDate.minusMaxAge().addingSeconds(1)
        
        sut.validateCache()
        store.completeRetrieveSuccessfully(result: (feed.local, nonExpiredDate))
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func makeSUT(timestamp: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, timestamp: timestamp)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return (store, sut)
    }
    
}

