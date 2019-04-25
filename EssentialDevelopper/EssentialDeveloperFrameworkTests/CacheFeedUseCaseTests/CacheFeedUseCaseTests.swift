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
    
    init(store: FeedStore) {
        self.store = store
    }
    
    func save(_ items: [FeedItem]) {
        self.store.save(items)
    }
    
    func deleteCache() {
        store.deleteCache { error in }
    }
}

class FeedStore {
    typealias DeletionCallback = (Error?) -> Void
    
    var items = [FeedItem]()
    
    var deleteCallCount = 0
    var insertCallCount = 0
    
    var deletionCompletions = [DeletionCallback]()

    func save(_ items: [FeedItem]) {
        self.deleteCache { [unowned self] error in
            if error == nil {
                self.insertCallCount += 1
                self.items = items
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
    
    func test_save_savesTheCorrectItems() {
        let (store, sut) = makeSUT()
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items)
        store.completeSuccesfully()
        
//        XCTAssertEqual(store.items, items)
        XCTAssertEqual(store.deleteCallCount, 1)
        XCTAssertEqual(store.insertCallCount, 1)
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
