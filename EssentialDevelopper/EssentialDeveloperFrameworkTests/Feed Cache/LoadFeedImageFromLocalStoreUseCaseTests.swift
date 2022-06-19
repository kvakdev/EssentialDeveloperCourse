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
    private var completion: Closure<FeedImageLoader.Result>?
    
    init(completion: @escaping (FeedImageLoader.Result) -> Void) {
        self.completion = completion
    }
    
    func complete(with result: FeedImageLoader.Result) {
        self.completion?(result)
    }
    
    func cancel() {
        completion = nil
    }
}

class LocalFeedImageLoader: FeedImageLoader {
    let store: ImageStoreSpy
    
    init(store: ImageStoreSpy) {
        self.store = store
    }
    
    func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = LocalImageLoaderTask(completion: completion)
        
        store.retreiveImage(with: url) { result in
            switch result {
            case .failure(let error):
                task.complete(with: .failure(error))
                print("")
            default:
                fatalError()
            }
        }
        
        return task
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
    
    func test_retreival_neverCallsbackAfterTaskIsCancelled() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImage(with: url) { _ in
            XCTFail("Expected callback to never be called after task cancellation")
        }
        task.cancel()
        store.complete(with: anyNSError(), at: 0)
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
