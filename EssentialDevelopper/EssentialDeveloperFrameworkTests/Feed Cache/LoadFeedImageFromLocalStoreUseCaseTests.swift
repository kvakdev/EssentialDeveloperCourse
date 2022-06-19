//
//  CacheFeedImageUseCase.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed

class LocalImageLoaderTask: FeedImageDataLoaderTask {
    func cancel() {}
}

class LocalFeedImageLoader: FeedImageLoader {
    let store: ImageStoreSpy
    
    init(store: ImageStoreSpy) {
        self.store = store
    }
    
    func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        store.retreiveImage(with: url) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
                print("")
            default:
                fatalError()
            }
        }
        
        return LocalImageLoaderTask()
    }
}

class ImageStoreSpy {
    var messages: [(url: URL, completion: (Result<Data?, Error>) -> Void)] = []
    
    func retreiveImage(with url: URL, completion: @escaping (Result<Data?, Error>) -> Void) {
        messages.append((url: url, completion: completion))
    }
    
    func complete(with error: Error, at index: Int = 0) {
        self.messages[index].completion(.failure(error))
    }
}

class LoadFeedImageFromLocalStoreUseCaseTests: XCTestCase {

    func test_init_doesNotMessageOnCreation() {
        let store = ImageStoreSpy()
        _ = LocalFeedImageLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    func test_retreiveError_deliversError() {
        let (sut, store) = makeSUT()
        let expectedError = anyNSError()
        
        let retreivedResult = result(from: sut, store: store) {
            store.complete(with: expectedError, at: 0)
        }

        switch retreivedResult {
        case .failure(let error):
            XCTAssertEqual((error as NSError), expectedError)
        default:
            XCTFail("EXpected error got \(retreivedResult.debugDescription) instead")
        }
    }
    
    func result(from sut: LocalFeedImageLoader, store: ImageStoreSpy, when action: VoidClosure) -> FeedImageLoader.Result? {
        let exp = expectation(description: "wait for load to complete")
        var retreivedResult: FeedImageLoader.Result?
        
        _ = sut.loadImage(with: anyURL()) { result in
            retreivedResult = result
            exp.fulfill()
        }
        action()
        
        wait(for: [exp], timeout: 1)
        
        return retreivedResult
    }
  
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (LocalFeedImageLoader, ImageStoreSpy) {
        let store = ImageStoreSpy()
        let sut = LocalFeedImageLoader(store: store)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(store)
        
        return (sut, store)
    }
}
