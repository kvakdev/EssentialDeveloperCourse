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
    typealias TransactionCompletion = (Error?) -> Void
    
    var deletionCallCount = 0
    var insertionCallCount = 0
    var deletionCompletions: [TransactionCompletion] = []
    var insertionCompletions: [TransactionCompletion] = []
    
    var savedFeed: [(images: [FeedImage], timestamp: Date)] = []
    
    func deleteCache(completion: @escaping TransactionCompletion) {
        deletionCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func insert(_ feedImages: [FeedImage], timestamp: Date, completion: @escaping TransactionCompletion) {
        insertionCallCount += 1
        savedFeed.append((feedImages, timestamp))
        insertionCompletions.append(completion)
    }
    
    func completeDeletionWith(_ error: Error?, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeInsertionWith(_ error: Error?, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
}

class LocalFeedLoader {
    let store: FeedStore
    let timestamp: () -> Date
    
    init(_ store: FeedStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.timestamp = timestamp
    }
    
    func save(_ feedImages: [FeedImage], completion: @escaping (Error?) -> Void) {
        store.deleteCache() { [unowned self] error in
            if error == nil {
                self.store.insert(feedImages, timestamp: timestamp(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_deletionIsNotInvoked_uponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.deletionCallCount, 0)
    }
    
    func test_deletionIsCalled_uponInsertion() {
        let (sut, store) = makeSUT()
        sut.save([]) { _ in }
        
        XCTAssertEqual(store.deletionCallCount, 1)
    }
    
    func test_insertionIsInvoked_uponSuccessfulDeletion() {
        let (sut, store) = makeSUT()
        expect(sut: sut, toCompleteWith: nil) {
            store.completeDeletionWith(nil)
            store.completeInsertionWith(nil)
        }
    }
    
    func test_insertionInNotInvoked_uponDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = NSError(domain: "deletionError", code: 0)

        expect(sut: sut, toCompleteWith: deletionError) {
            store.completeDeletionWith(deletionError)
        }
    }
    
    func test_feedStoreSavesCorrectFeedWithCorrectTimestamp_uponInsertion() {
        let timestamp = Date()
        let (sut, store) = makeSUT(timestamp: { timestamp })
        let images = [uniqueFeedImage(), uniqueFeedImage()]
        let exp = expectation(description: "waiting for save to complete")
        
        sut.save(images) { error in
            exp.fulfill()
        }
        store.completeDeletionWith(nil)
        store.completeInsertionWith(nil)
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(store.savedFeed.first?.images, images)
        XCTAssertEqual(store.savedFeed.first?.timestamp, timestamp)
        XCTAssertEqual(store.savedFeed.count, 1)
    }
    
    private func expect(sut: LocalFeedLoader, toCompleteWith expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for save to complete")
        var receivedError: Error?
        
        sut.save([uniqueFeedImage()]) { error in
            receivedError = error
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual((receivedError as? NSError)?.code, expectedError?.code, file: file, line: line)
        XCTAssertEqual((receivedError as? NSError)?.domain, expectedError?.domain, file: file, line: line)
    }
    
    private func makeSUT(timestamp: @escaping () -> Date = Date.init) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store, timestamp: timestamp)
        
        return (sut: sut, store: store)
    }
    
    private func uniqueFeedImage() -> FeedImage {
        return FeedImage(id: UUID(), imageUrl: anyURL())
    }
}
