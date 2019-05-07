//
//  LoadFeedFromCacheUseCaseTest.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 4/26/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class LoadFeedFromCacheUseCaseTest: XCTestCase {

    func test_retrieve_shouldReturnSuccessfulResultWithRetrievedItems() {
        let timestamp = Date()
        let (store, sut) = makeSUT(timestamp: { timestamp })
        let items = uniqueImageFeed()
       
        expect(sut: sut, toCompleteWith: .success(items.models)) {
            store.completeRetrieveSuccessfully(result: (items.local, timestamp))
        }
    }
    
    func test_retrieve_shouldReturnErrorOnRetrievalError() {
        let (store, sut) = makeSUT()
        let retrievalError = anyNSError()
        
        expect(sut: sut, toCompleteWith: .failure(retrievalError)) {
            store.completeRetrieval(with: retrievalError)
        }
    }
    
    func test_retrieve_returnsNoResultsOnEmptyCache() {
        let (store, sut) = makeSUT()
        let date = Date()
        
        expect(sut: sut, toCompleteWith: .success([])) {
            store.completeRetrieveSuccessfully(result: ([], date))
        }
    }
    
    func test_load_hasNoSideEffectsOnRetrievalError() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotDeleteCacheOnEmptyCache() {
        let (store, sut) = makeSUT()
        
        sut.load { _ in }
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_doesNotHaveSideEffectsOnLessThanSevenDaysOldCache() {
        let fixedDate = Date()
        let (store, sut) = makeSUT(timestamp: { fixedDate })
        let feed = uniqueImageFeed()
        
        sut.load { _ in }
        store.completeRetrieveSuccessfully(result: (feed.local, fixedDate.addingDays(-7).addingSeconds(1)))
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_returnsFeedOnValidCacheTimestamp() {
        let timestamp = Date().addingDays(-7).addingSeconds(1)
        let (store, sut) = makeSUT()
        let feed = uniqueImageFeed()
        
        expect(sut: sut, toCompleteWith: .success(feed.models)) {
            store.completeRetrieveSuccessfully(result: (feed.local, timestamp))
        }
    }
    
    func test_load_doesNotDeliverResultsAfterSUTHasBeenDeallocated() {
        var sut: LocalFeedLoader?
        let store = FeedStoreSpy()
        sut = LocalFeedLoader(store: store, timestamp: Date.init)
        var capturedResult = [LocalFeedLoader.Result]()
        
        sut!.load { capturedResult.append($0) }
        sut = nil
        store.completeRetrievalWithEmptyCache()
        
        XCTAssertTrue(capturedResult.isEmpty)
    }
    
    func expect(sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.Result, file: StaticString = #file, line: UInt = #line, when action: () -> Void) {
        let exp = expectation(description: "waiting for retrieve to complete")
        
        sut.load { result in
            switch (result, expectedResult) {
                case let (.success(imageFeed), .success(expectedImageFeed)):
                    XCTAssertEqual(imageFeed, expectedImageFeed, file: file, line: line)
                
                case let (.failure(error as NSError), .failure(expectedError as NSError)):
                    XCTAssertEqual(error, expectedError)
                
                default:
                    XCTFail("expected \(expectedResult) got \(result) instead")
            }
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func makeSUT(timestamp: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, timestamp: timestamp)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return (store, sut)
    }
}
