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
    
    func expect(sut: LocalFeedLoader, toCompleteWith expectedResult: LocalFeedLoader.Result, when action: () -> Void) {
        let exp = expectation(description: "waiting for retrieve to complete")
        
        sut.retrieveFeed { result in
            switch (result, expectedResult) {
                case let (.success(imageFeed, timestamp), .success(expectedImageFeed, expectedTimestamp)):
                    XCTAssertEqual(imageFeed, expectedImageFeed)
                    XCTAssertEqual(timestamp, expectedTimestamp)
                
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
