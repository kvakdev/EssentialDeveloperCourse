//
//  CacheFeedUseCaseTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 4/25/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class LocalFeedLoader {
    private let store: FeedStore
    private let timestamp: () -> Date
    
    init(store: FeedStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.timestamp = timestamp
    }
    
    func save(_ items: [FeedItem]) {
        self.store.save(items, timestamp: self.timestamp())
    }
    
    func deleteCache() {
        store.deleteCache { error in }
    }
}

class FeedStore {
    typealias DeletionCallback = (Error?) -> Void
    
    private var feedCache: FeedItemCache?
    
    var items: [FeedItem] {
        return feedCache?.items ?? []
    }
    
    var timestamp: Date? {
        return feedCache?.timestamp
    }
    
    private struct FeedItemCache {
        let items: [FeedItem]
        let timestamp: Date
    }
    
    var deleteCallCount = 0
    var insertCallCount = 0
    
    var deletionCompletions = [DeletionCallback]()

    func save(_ items: [FeedItem], timestamp: Date) {
        self.deleteCache { [unowned self] error in
            if error == nil {
                self.insertCallCount += 1
                self.feedCache = FeedItemCache(items: items, timestamp: timestamp)
            }
        }
    }
    
    func deleteCache(completion: @escaping DeletionCallback) {
        deleteCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletionWith(error: Error?, at index: Int = 0) {
        self.deletionCompletions[index](error)
    }
    
    func completeSuccesfully(at index: Int = 0) {
        self.deletionCompletions[index](nil)
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
        
        XCTAssertTrue(store.deleteCallCount == 1)
    }
    
    func test_save_callDeleteAndInsertOnSuccesfulDeletion() {
        let (store, sut) = makeSUT()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items)
        store.completeSuccesfully()
        
        XCTAssertEqual(store.deleteCallCount, 1)
        XCTAssertEqual(store.insertCallCount, 1)
    }
    
    func test_save_savesTheCorrectItemsWithCorrectTimestamp() {
        let timestamp = Date()
        let (store, sut) = makeSUT(timestamp: { timestamp })
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items)
        store.completeSuccesfully()
        
        XCTAssertEqual(store.timestamp, timestamp)
        XCTAssertEqual(store.items, items)
    }
    
    func makeSUT(timestamp: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (store: FeedStore, sut: LocalFeedLoader) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, timestamp: timestamp)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return (store, sut)
    }
    
    func uniqueFeedItem() -> FeedItem {
        return FeedItem(id: UUID(), imageUrl: URL(string: "http://any-url.com")!)
    }
}
