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
       
        expect(sut: sut, toCompleteWith: .success(items.models, timestamp)) {
            store.completeRetrieveSuccessfully(result: (items.models, timestamp))
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
        
        expect(sut: sut, toCompleteWith: .success([], date)) {
            store.completeRetrieveSuccessfully(result: ([], date))
        }
    }
    
    func test_load_returnsEmptyFeedOnExpiredCacheAndSuccessfullDeletion() {
        let timestamp = Date()
        let expiredTimestamp = timestamp.addingDays(-7).addingSeconds(-1)
        let (store, sut) = makeSUT(timestamp: { timestamp })
        let feed = uniqueImageFeed().models
        
        expect(sut: sut, toCompleteWith: .success([], expiredTimestamp)) {
            store.completeRetrieveSuccessfully(result: (feed, expiredTimestamp))
            store.completeDeletionSuccessfully()
        }
    }
    
    func test_load_returnsFeedOnExactMatchingCacheTimestamp() {
        let fixedDate = Date()
        let (store, sut) = makeSUT(timestamp: { fixedDate })
        let feed = uniqueImageFeed().models
        
        expect(sut: sut, toCompleteWith: .success(feed, fixedDate.addingDays(-7))) {
            store.completeRetrieveSuccessfully(result: (feed, fixedDate.addingDays(-7)))
        }
    }
    
    func test_load_returnsFeedOnValidCacheTimestamp() {
        let timestamp = Date().addingDays(-7).addingSeconds(1)
        let (store, sut) = makeSUT()
        let feed = uniqueImageFeed().models
        
        expect(sut: sut, toCompleteWith: .success(feed, timestamp)) {
            store.completeRetrieveSuccessfully(result: (feed, timestamp))
        }
    }
    
    func expect(sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.LoadFeedResult, file: StaticString = #file, line: UInt = #line, when action: () -> Void) {
        let exp = expectation(description: "waiting for retrieve to complete")
        
        sut.load { result in
            switch (result, expectedResult) {
                case let (.success(imageFeed, timestamp), .success(expectedImageFeed, expectedTimestamp)):
                    XCTAssertEqual(imageFeed, expectedImageFeed, file: file, line: line)
                    XCTAssertEqual(timestamp, expectedTimestamp, file: file, line: line)
                
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

fileprivate extension Date {
    func addingDays(_ amount: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: amount, to: self)!
    }
    
    func addingSeconds(_ amount: TimeInterval) -> Date {
        return self.addingTimeInterval(amount)
    }
}
