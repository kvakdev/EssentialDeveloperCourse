//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Andre Kvashuk on 6/5/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed

class CacheFeedUseCaseTests: XCTestCase {
    
    func test_deletionIsNotInvoked_uponCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertEqual(store.savedMessages, [])
    }

    func test_saveSucceeds_uponSuccessfulInsertion() {
        let (sut, store) = makeSUT()
        expect(sut: sut, toCompleteWith: .success(())) {
            store.successfulyCompleteDeletion()
            store.successfulyCompleteInsertion()
        }
    }
    
    func test_saveFailsWithDeletionError_uponDeletionError() {
        let (sut, store) = makeSUT()
        let deletionError = NSError(domain: "deletionError", code: 0)

        expect(sut: sut, toCompleteWith: .failure(deletionError)) {
            store.completeDeletionWith(deletionError)
        }
    }
    
    func test_saveFailsWithCorrectError_uponInsertionError() {
        let (sut, store) = makeSUT()
        let insertionError = NSError(domain: "insertionError", code: 0)
        
        expect(sut: sut, toCompleteWith: .failure(insertionError)) {
            store.successfulyCompleteDeletion()
            store.completeInsertionWith(insertionError)
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
        store.successfulyCompleteDeletion()
        store.successfulyCompleteInsertion()
        
        wait(for: [exp], timeout: 1)
        XCTAssertEqual(store.savedMessages, [.delete, .insert(images: images.toLocal(), timestamp: timestamp)])
    }
    
    func test_saveDoesNotDeliverDeletionError_afterLoaderIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store, timestamp: Date.init)
        var receivedResults: [LocalFeedLoader.SaveResult] = []
        sut?.save([uniqueFeedImage()], completion: { result in
            receivedResults.append(result)
        })
        
        sut = nil
        store.completeDeletionWith(NSError())
        
        XCTAssertEqual(receivedResults.count, 0)
    }
    
    func test_saveDoesNotDeliverInsertionError_afterLoaderIsDeallocated() {
        let store = FeedStoreSpy()
        var sut: LocalFeedLoader? = LocalFeedLoader(store, timestamp: Date.init)
        var receivedResults: [LocalFeedLoader.SaveResult] = []
        sut?.save([uniqueFeedImage()], completion: { result in
            receivedResults.append(result)
        })
        
        store.successfulyCompleteDeletion()
        sut = nil
        store.completeInsertionWith(NSError())
        
        XCTAssertEqual(receivedResults.count, 0)
    }
    
    private func expect(sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.SaveResult, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "waiting for save to complete")
        var receivedResult: LocalFeedLoader.SaveResult?
        
        sut.save([uniqueFeedImage()]) { result in
            receivedResult = result
            exp.fulfill()
        }
        action()
        wait(for: [exp], timeout: 1.0)
        
        XCTAssertEqual((receivedResult as? NSError)?.code, (expectedResult as? NSError)?.code, file: file, line: line)
        XCTAssertEqual((receivedResult as? NSError)?.domain, (expectedResult as? NSError)?.domain, file: file, line: line)
    }
    
    private func makeSUT(timestamp: @escaping () -> Date = Date.init) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store, timestamp: timestamp)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(store)
        
        return (sut: sut, store: store)
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        compactMap { LocalFeedImage(id: $0.id,
                                    description: $0.description,
                                    location: $0.location,
                                    url: $0.url)
        }
    }
}
