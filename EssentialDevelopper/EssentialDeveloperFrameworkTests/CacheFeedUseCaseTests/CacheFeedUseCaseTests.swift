//
//  CacheFeedUseCaseTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 4/25/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class FeedStore {
    var deletionCallCount = 0
    var items = [FeedItem]()
    
    func save(_ items: [FeedItem]) {
        self.items = items
    }
    
    func deleteCache() {
        deletionCallCount += 1
    }
}

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        self.store.save(items)
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
    
    func test_save_savesTheCorrectItems() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        let item1 = uniqueFeedItem()
        let item2 = uniqueFeedItem()
        let items = [item1, item2]
        
        sut.save(items)
        
        XCTAssertEqual(store.items, items)
    }
    
    func uniqueFeedItem() -> FeedItem {
        return FeedItem(id: UUID(), imageUrl: URL(string: "http://any-url.com")!)
    }
}
