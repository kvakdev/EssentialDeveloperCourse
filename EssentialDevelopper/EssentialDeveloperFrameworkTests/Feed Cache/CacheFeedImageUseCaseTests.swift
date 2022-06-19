//
//  CacheFeedImageUseCaseTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed

class CacheFeedImageUseCaseTests: XCTestCase {
    
    func test_init_doesNotMessageOnCreation() {
        let (_, store) = makeSUT()
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_save_triggersInsertInFeedImageStore() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()
        
        sut.save(image: data, for: url) { _ in }
        
        XCTAssertEqual(store.messages, [.insert(url: url, data: data)])
    }
    
    func test_save_deliversErrorOnInsertError() {
        let (sut, store) = makeSUT()
        let data = anyData()
        let url = anyURL()
        let exp = expectation(description: "wait for insert to complete")
        let expectedError = anyNSError()
        
        sut.save(image: data, for: url) { result in
            switch result {
            case .failure:
                break
            case .success:
                XCTFail("Expected to get error on insertion error got \(result) instead")
            }
            exp.fulfill()
        }
        store.insertComplete(with: expectedError)
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LocalFeedImageLoader, ImageStoreSpy) {
        let store = ImageStoreSpy()
        let sut = LocalFeedImageLoader(store: store)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(store)
        
        return (sut, store)
    }
    
}
