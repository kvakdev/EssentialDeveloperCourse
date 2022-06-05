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
