//
//  CacheFeedImageUseCase.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed


class RetreiveTaskSpy: CancellableTask {
    private let cancelClosure: VoidClosure
    
    init(cancelClosure: @escaping VoidClosure) {
        self.cancelClosure = cancelClosure
    }
    
    func cancel() {
        self.cancelClosure()
    }
}

class ImageStoreSpy: ImageStore {
    var messages: [(url: URL, completion: (Result<Data?, Error>) -> Void)] = []
    
    var cancelledURLs: [URL] = []
    
    @discardableResult
    func retreiveImageData(from url: URL, completion: @escaping (Result<Data?, Error>) -> Void) -> CancellableTask {
        messages.append((url: url, completion: completion))
        
        return RetreiveTaskSpy(cancelClosure: { [weak self] in self?.cancelledURLs.append(url) })
    }
    
    func complete(with error: Error, at index: Int = 0) {
        self.messages[index].completion(.failure(error))
    }
    
    func complete(with data: Data? = nil, at index: Int = 0) {
        self.messages[index].completion(.success(data))
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
        
        expect(sut: sut, toLoad: .failure(expectedError)) {
            store.complete(with: expectedError, at: 0)
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
    
    func test_cancellingTask_cancelsRetreivalTask() {
        let (sut, store) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImage(with: url) { _ in }
        task.cancel()
        XCTAssertEqual(store.cancelledURLs, [url])
    }
    
    func test_load_deliversNilDataOnEmptyRetreival() {
        let (sut, store) = makeSUT()
        
        expect(sut: sut, toLoad: .failure(ImageRetreivalError.noImage)) {
            store.complete(with: nil, at: 0)
        }
    }
    
    func test_load_deliversDataRetreivedByTheStore() {
        let (sut, store) = makeSUT()
        let expectedData = anyData()
        
        expect(sut: sut, toLoad: .success(expectedData)) {
            store.complete(with: expectedData, at: 0)
        }
    }
    
    func test_load_doesNotCallCompletionAfterInstanceHasBeenDelallocated() {
        var (sut, store): (LocalFeedImageLoader?, ImageStoreSpy) = makeSUT()
        let url = anyURL()
        
        _ = sut!.loadImage(with: url) { _ in
            XCTFail("Expected to never be called after instance deallocation")
        }
        
        sut = nil
        store.complete()
        store.complete(with: anyNSError(), at: 0)
        store.complete(with: anyData(), at: 0)
    }
    
    private func expect(sut: LocalFeedImageLoader, toLoad expectedResult: FeedImageLoader.Result, when action: @escaping VoidClosure, file: StaticString = #file, line: UInt = #line) {
        
        let retreivedResult = result(from: sut, when: action)
        
        switch (retreivedResult, expectedResult) {
        case (.success(let retreivedData), .success(let expectedData)):
            XCTAssertEqual(retreivedData, expectedData, file: file, line: line)
        case (.failure(let retreivedError), .failure(let expectedError)):
            XCTAssertEqual(retreivedError.localizedDescription, expectedError.localizedDescription, file: file, line: line)
        default:
            XCTFail("Expected to get \(expectedResult), got \(String(describing: retreivedResult)) instead", file: file, line: line)
        }
    }
    
    private func result(from sut: LocalFeedImageLoader, when action: VoidClosure) -> FeedImageLoader.Result? {
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
