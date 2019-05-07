//
//  ValidateCachedFeedUseCaseTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 5/7/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class ValidateCachedFeedUseCaseTests: XCTestCase {
    
    func test_init_doesNotHaveSideEffects() {
        let (store, _) = makeSUT()
        
        XCTAssertTrue(store.receivedMessages.isEmpty)
    }
    
    func test_validate_deletesCacheOnRetrievalError() {
        let (store, sut) = makeSUT()
        
        sut.validate()
        
        store.completeRetrieval(with: anyNSError())
        
        XCTAssertEqual(store.receivedMessages, [.retrieve, .delete])
    }
    
    func makeSUT(timestamp: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (store: FeedStoreSpy, sut: LocalFeedLoader) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, timestamp: timestamp)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(store, file: file, line: line)
        
        return (store, sut)
    }
    
}

