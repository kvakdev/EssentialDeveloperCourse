//
//  CacheFeedUseCaseTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 4/25/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest

class FeedStore {
    var deletionCallCount = 0
    
    func deleteCache() {
        deletionCallCount += 1
    }
}

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func deleteCache() {
        store.deleteCache()
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCacheCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store: store)
        
        XCTAssertTrue(store.deletionCallCount == 0)
    }
    
    func test_delete_incrementsDeletionCallCount() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        sut.deleteCache()
        
        XCTAssertTrue(store.deletionCallCount == 1)
    }
    
}
