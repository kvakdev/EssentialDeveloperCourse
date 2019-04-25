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
        self.store.deleteCache { [unowned self] error in
            if error == nil {
                self.store.save(items, timestamp: self.timestamp())
            }
        }
    }
}

class FeedStore {
    typealias DeletionCallback = (Error?) -> Void
        
    enum FeedStoreMessages: Equatable {
        case delete
        case insert([FeedItem], Date)
    }
    
    var receivedMessages = [FeedStoreMessages]()
    
    private struct FeedItemCache {
        let items: [FeedItem]
        let timestamp: Date
    }
    
    var deletionCompletions = [DeletionCallback]()

    func save(_ items: [FeedItem], timestamp: Date) {
        self.receivedMessages.append(.insert(items, timestamp))
    }
    
    func deleteCache(completion: @escaping DeletionCallback) {
        deletionCompletions.append(completion)
        receivedMessages.append(.delete)
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
        
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_save_callDeleteAndInsertOnSuccesfulDeletionWithCorrectTimeStamp() {
        let timestamp = Date()
        let (store, sut) = makeSUT(timestamp: { timestamp })
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items)
        store.completeSuccesfully()
        
        XCTAssertEqual(store.receivedMessages, [.delete, .insert(items, timestamp)])
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
