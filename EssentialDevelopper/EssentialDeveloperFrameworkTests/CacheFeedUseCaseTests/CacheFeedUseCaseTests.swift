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
    var items = [FeedItem]()
    
    func save(_ items: [FeedItem]) {
        self.items = items
    }
    
    func deleteCache() {
        self.items = []
    }
}

class LocalFeedLoader {
    private let store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        self.store.deleteCache()
        self.store.save(items)
    }
    
    func deleteCache() {
        store.deleteCache()
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotDeleteCacheUponCacheCreation() {
        let (store, _) = makeSUT()
        
        XCTAssertTrue(store.items.isEmpty)
    }
    
    func test_delete_incrementsDeletionCallCount() {
        let (store, sut) = makeSUT()
        
        sut.deleteCache()
        
        XCTAssertTrue(store.items.isEmpty)
    }
    
    func test_save_savesTheCorrectItems() {
        let (store, sut) = makeSUT()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items)
        
        XCTAssertEqual(store.items, items)
    }
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (store: FeedStore, sut: LocalFeedLoader) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return (store, sut)
    }
    
    func uniqueFeedItem() -> FeedItem {
        return FeedItem(id: UUID(), imageUrl: URL(string: "http://any-url.com")!)
    }
}
