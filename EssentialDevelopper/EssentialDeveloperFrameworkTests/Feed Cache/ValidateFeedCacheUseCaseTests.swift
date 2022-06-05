//
//  ValidateFeedCacheUseCaseTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/5/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class ValidateFeedCacheUseCaseTests: XCTestCase {
    
    func test_init_doesNotHaveSideEffects() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.savedMessages, [])
    }
    
    func test_validateFeed_deletesCacheOnRetrievalError() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieveWith(anyNSError())
        
        XCTAssertEqual(store.savedMessages, [.retrieve, .delete])
    }
    
    func test_validateFeed_hasNoSideEffectsOnLessThanSevenDaysOldCache() {
        let (sut, store) = makeSUT()
        
        sut.validateCache()
        store.completeRetrieveWith([uniqueFeed().local], timestamp: Date())
        
        XCTAssertEqual(store.savedMessages, [.retrieve])
    }
    
    func test_validate_deletesCacheOnSevenDaysOldCache() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        
        sut.validateCache()
        store.completeRetrieveWith([], timestamp: fixedDate.adding(days: -7))
        
        XCTAssertEqual(store.savedMessages, [.retrieve, .delete])
    }
    
    func test_validate_deletesCacheOnMoreThanSevenDaysOldCache() {
        let fixedDate = Date()
        let (sut, store) = makeSUT(timestamp: { fixedDate })
        
        sut.validateCache()
        store.completeRetrieveWith([], timestamp: fixedDate.adding(days: -7).adding(seconds: -1))
        
        XCTAssertEqual(store.savedMessages, [.retrieve, .delete])
    }
    
    func test_validate_doesNotDeleCacheAfterSutHasBeenDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store, timestamp: { Date() })
        
        sut?.validateCache()
        sut = nil
        store.completeRetrieveWith(anyNSError())
        XCTAssertEqual(store.savedMessages, [.retrieve])
    }
    
    private func makeSUT(timestamp: @escaping () -> Date = Date.init) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store, timestamp: timestamp)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(store)
        
        return (sut: sut, store: store)
    }
}
