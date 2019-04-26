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
    
    enum Result {
        case success([FeedItem], Date)
        case failure(Error)
    }
    
    init(store: FeedStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.timestamp = timestamp
    }
    
    func save(_ items: [FeedItem], completion: @escaping (Error?) -> Swift.Void) {
        self.store.deleteCache { [unowned self] error in
            if error == nil {
                self.store.insert(items, timestamp: self.timestamp(), completion: completion)
            } else {
                completion(error)
            }
        }
    }
    
    func retrieveFeed(completion: @escaping (Result) -> Swift.Void) {
        self.store.retrieve() { [unowned self] result in
            switch result {
            case .failure:
                completion(result)
            case .success(let feedItems, let timestamp):
                if self.isValidTimestamp(timestamp) {
                    completion(.success(feedItems, timestamp))
                }
            }
        }
    }
    
    func isValidTimestamp(_ timestamp: Date) -> Bool {
        return timestamp.addingTimeInterval(7*24*60*60) > Date()
    }
    
}

class FeedStore {
    typealias DeletionCallback = (Error?) -> Void
    typealias InsertionCallback = (Error?) -> Void
    typealias RetrieveCallback = (LocalFeedLoader.Result) -> Void
    
    enum FeedStoreMessages: Equatable {
        case delete
        case insert([FeedItem], Date)
        case retrieve
    }
    
    var receivedMessages = [FeedStoreMessages]()
    
    private struct FeedItemCache {
        let items: [FeedItem]
        let timestamp: Date
    }
    
    var deletionCompletions = [DeletionCallback]()
    var retrieveCompletions = [RetrieveCallback]()
    var insertionCompletions = [InsertionCallback]()
    
    private var cachedFeed: FeedItemCache?
    
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCallback) {
        self.cachedFeed = FeedItemCache(items: items, timestamp: timestamp)
        self.receivedMessages.append(.insert(items, timestamp))
        self.insertionCompletions.append(completion)
    }
    
    func deleteCache(completion: @escaping DeletionCallback) {
        deletionCompletions.append(completion)
        receivedMessages.append(.delete)
    }
    
    func completeDeletionWith(error: Error?, at index: Int = 0) {
        self.deletionCompletions[index](error)
    }
    
    func completeDeletionSuccessfully(at index: Int = 0) {
        self.deletionCompletions[index](nil)
    }
    
    func completeRetrieveSuccessfully(at index: Int = 0, date: Date = Date()) {
        self.retrieveCompletions[index](.success(cachedFeed?.items ?? [], cachedFeed?.timestamp ?? date))
    }
    
    func completeRetrieval(at index: Int = 0, with error: Error) {
        self.retrieveCompletions[index](.failure(error))
    }
    
    func completeInsertion(with error: Error?, at index: Int = 0) {
        self.insertionCompletions[index](error)
    }
    
    func completeInsertionSuccessfully(at index: Int = 0) {
        self.insertionCompletions[index](nil)
    }
    
    func retrieve(completion: @escaping (LocalFeedLoader.Result) -> Swift.Void) {
        self.receivedMessages.append(.retrieve)
        self.retrieveCompletions.append(completion)
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
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        store.completeInsertionSuccessfully()
        
        XCTAssertEqual(store.receivedMessages, [.delete, .insert(items, timestamp)])
    }
    
    func test_save_shouldFailOnInsertionError() {
        let (store, sut) = makeSUT()
        let insertionError = anyNSError()
        
        expect(sut: sut, toCompleteWithError: insertionError) {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        }
    }
    
    func test_save_shouldReturnErrorOnDeletionError() {
        let (store, sut) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut: sut, toCompleteWithError: deletionError) {
            store.completeDeletionWith(error: deletionError)
        }
    }
    
    func test_save_shouldCompleteWithNoError() {
        let (store, sut) = makeSUT()
        
        expect(sut: sut, toCompleteWithError: nil) {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        }
    }

    func test_retrieve_shouldReturnEmptyFeedIfNoFeedIsCached() {
        let timestamp = Date()
        let (store, sut) = makeSUT()
        let exp = expectation(description: "waiting for retrieve")
        
        sut.retrieveFeed() { result in
            switch result {
            case .success(let receivedItems, let receivedTimestamp):
                XCTAssertEqual(receivedItems, [])
                XCTAssertEqual(receivedTimestamp, timestamp)
            case .failure:
                XCTFail("expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        store.completeRetrieveSuccessfully(date: timestamp)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func expect(sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void) {
        let exp = expectation(description: "waiting for command to complete")
        
        sut.save([uniqueFeedItem()]) { error in
            XCTAssertEqual(error as NSError?, expectedError)
            
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_shouldReturnMostRecentItemsThatWereSaved() {
        let timestamp = Date()
        let (store, sut) = makeSUT(timestamp: { timestamp })
        let exp = expectation(description: "waiting for retrieve")
        let items = [uniqueFeedItem(), uniqueFeedItem()]
        let items2 = [uniqueFeedItem(), uniqueFeedItem()]
        
        sut.save(items) { _ in }
        store.completeDeletionSuccessfully()
        
        sut.save(items2) { _ in }
        store.completeDeletionSuccessfully(at: 1)
        
        sut.retrieveFeed() { [unowned store] result in
            switch result {
            case .success(let receivedItems, let receivedTimestamp):
                XCTAssertEqual(receivedItems, items2)
                XCTAssertEqual(receivedTimestamp, timestamp)
                XCTAssertEqual(store.receivedMessages, [.delete, .insert(items, timestamp), .delete, .insert(items2, timestamp), .retrieve])
            case .failure:
                XCTFail("expected success, got \(result) instead")
            }
            exp.fulfill()
        }
        store.completeRetrieveSuccessfully(date: timestamp)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_returnsAnErrorOnRetrievalError() {
        let (store, sut) = makeSUT()
        let exp = expectation(description: "waiting for retrieve")
        let error = anyNSError()
        
        sut.retrieveFeed() { result in
            switch result {
            case .success:
                XCTFail("expected failure, got \(result) instead")
            default:
                break
            }
            exp.fulfill()
        }
        store.completeRetrieval(with: error)
        
        wait(for: [exp], timeout: 1.0)
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
    
    func anyNSError() -> NSError {
        return NSError(domain: "CacheFeedError", code: 1, userInfo: nil)
    }
}
