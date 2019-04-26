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
        self.store.deleteCache { [weak self] error in
            guard self != nil else { return }
            
            if error == nil {
                self!.store.insert(items, timestamp: self!.timestamp(), completion: completion)
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

protocol FeedStore {
    typealias DeletionCallback = (Error?) -> Void
    typealias InsertionCallback = (Error?) -> Void
    typealias RetrieveCallback = (LocalFeedLoader.Result) -> Void
    
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCallback)
    func retrieve(completion: @escaping (LocalFeedLoader.Result) -> Swift.Void)
    func deleteCache(completion: @escaping DeletionCallback)
}

class FeedStoreSpy: FeedStore {
    enum FeedStoreMessages: Equatable {
        case delete
        case insert([FeedItem], Date)
        case retrieve
    }
    
    var receivedMessages = [FeedStoreMessages]()
    
    var deletionCompletions = [DeletionCallback]()
    var retrieveCompletions = [RetrieveCallback]()
    var insertionCompletions = [InsertionCallback]()
    
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCallback) {
        self.receivedMessages.append(.insert(items, timestamp))
        self.insertionCompletions.append(completion)
    }
    
    func retrieve(completion: @escaping (LocalFeedLoader.Result) -> Swift.Void) {
        self.receivedMessages.append(.retrieve)
        self.retrieveCompletions.append(completion)
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
    
    func completeRetrieveSuccessfully(at index: Int = 0, result: (items: [FeedItem], date: Date)) {
        self.retrieveCompletions[index](.success(result.items, result.date))
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
        
        expect(sut: sut, toCompleteWithError: insertionError, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertion(with: insertionError)
        })
    }
    
    func test_save_shouldReturnErrorOnDeletionError() {
        let (store, sut) = makeSUT()
        let deletionError = anyNSError()
        
        expect(sut: sut, toCompleteWithError: deletionError, when: {
            store.completeDeletionWith(error: deletionError)
        })
    }
    
    func test_save_shouldCompleteWithNoError() {
        let (store, sut) = makeSUT()
        
        expect(sut: sut, toCompleteWithError: nil, when: {
            store.completeDeletionSuccessfully()
            store.completeInsertionSuccessfully()
        })
    }
    
    func expect(sut: LocalFeedLoader, toCompleteWithError expectedError: NSError?, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for command to complete")
        
        sut.save([uniqueFeedItem()]) { error in
            XCTAssertEqual(error as NSError?, expectedError, file: file, line: line)
            
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_save_deliversNoErrorAfterSUT_isDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store: store, timestamp: { Date() })
        var receivedErrors = [Error?]()
        
        sut!.save([uniqueFeedItem()]) { receivedErrors.append($0) }
        
        sut = nil
        store.completeDeletionWith(error: anyNSError())
        
        XCTAssertTrue(receivedErrors.isEmpty)
    }
    
    func makeSUT(timestamp: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, timestamp: timestamp)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return (store, sut)
    }
    
}
