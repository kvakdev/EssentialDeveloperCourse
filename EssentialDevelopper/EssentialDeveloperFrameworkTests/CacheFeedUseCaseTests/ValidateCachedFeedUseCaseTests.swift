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
        
        sut.validate()
        
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .delete])
    }
    
    func test_validate_deletesMoreThanSevenDaysOldCache() {
        let timestamp = Date()
        let moreThanSevenDaysOldDate = timestamp.addingDays(-7).addingSeconds(-1)
        let (store, sut) = makeSUT(timestamp: { timestamp })
        let feed = uniqueImageFeed()
        
        
        sut.validate()
        
        store.completeRetrieveSuccessfully(result: ( feed.local, moreThanSevenDaysOldDate ))
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .delete])
    }
    
    func test_validate_deletesSevenDaysOldCache() {
        let fixedDate = Date()
        let (store, sut) = makeSUT(timestamp: { fixedDate })
        let feed = uniqueImageFeed()
        
        sut.validate()
        store.completeRetrieveSuccessfully(result: (feed.local, fixedDate.addingDays(-7)))
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .delete])
    }
    
    func test_validate_doesNotDeleteLessThanSevenDaysOldCache() {
        let fixedDate = Date()
        let (store, sut) = makeSUT(timestamp: { fixedDate })
        let feed = uniqueImageFeed()
        
        sut.validate()
        store.completeRetrieveSuccessfully(result: (feed.local, fixedDate.addingDays(-7).addingSeconds(1)))
        
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

