//
//  CacheFeedUseCaseTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/5/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class FeedStore {
    var deletionCallCount = 0
    
    func deleteCache() {
        deletionCallCount += 1
    }
}

class LocalFeedLoader {
    let store: FeedStore
    
    init(_ store: FeedStore) {
        self.store = store
    }
    
    func save(_ feedImages: [FeedImage]) {
        store.deleteCache()
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_deletionIsNotInvoked_uponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store)
        
        XCTAssertEqual(store.deletionCallCount, 0)
    }
    
    func test_deletionIsCalled_uponInsertion() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store)
        let feedItems = [uniqueFeedImage(), uniqueFeedImage()]
        sut.save(feedItems)
        
        XCTAssertEqual(store.deletionCallCount, 1)
    }
    
    private func uniqueFeedImage() -> FeedImage {
        return FeedImage(id: UUID(), imageUrl: anyURL())
    }
}
