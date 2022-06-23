//
//  ImageLoaderWithFallbackCompositTests.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/23/22.
//

import XCTest
import EssentialFeed
import EssentialApp
@testable import EssentialFeed_iOS

class CancellableTask: FeedImageDataLoaderTask {
    func cancel() {}
}



class ImageLoaderWithFallbackCompositTests: XCTestCase {
    
    func test_loader_deliversImageDataInPrimarySucceeds() {
        let expectedData = Data("data".utf8)
        let primaryLoader = ImageLoaderStub(stub: .success(expectedData))
        let fallbackLoader = ImageLoaderStub(stub: .failure(anyNSError()))
        let sut = makeSUT(primaryLoader: primaryLoader, fallbackLoader: fallbackLoader)
        
        expect(sut: sut, toLoadResult: .success(expectedData))
    }
    
    func test_loader_deliversFallbackImageDataWhenPrimaryLoaderFails() {
        let expectedData = Data("data".utf8)
        let sut = makeSUT(
            primaryLoader: ImageLoaderStub(stub: .failure(anyNSError())),
            fallbackLoader: ImageLoaderStub(stub: .success(expectedData)))
        
        expect(sut: sut, toLoadResult: .success(expectedData))
    }
    
    func test_loader_doesNotReturnResultOnTaskCancelBeforePrimaryCallback() {
        let primaryLoader = ImageLoaderStub(stub: .success(anyData()), autoComplete: false)
        let fallbackLoader = ImageLoaderStub(stub: .failure(anyError()))
        let sut = makeSUT(primaryLoader: primaryLoader,
                          fallbackLoader: fallbackLoader)
        
        let task = sut.loadImage(with: anyURL()) { result in
            XCTFail("Expected no result after task cancel")
        }
        
        task.cancel()
        primaryLoader.complete()
        fallbackLoader.complete()
    }
    
    func test_loader_doesNotReturnResultOnTaskCancelAfterPrimaryLoaderFailed() {
        let primaryLoader = ImageLoaderStub(stub: .failure(anyError()))
        let fallbackLoader = ImageLoaderStub(stub: .failure(anyError()), autoComplete: false)
        let sut = makeSUT(primaryLoader: primaryLoader,
                          fallbackLoader: fallbackLoader)
        
        let task = sut.loadImage(with: anyURL()) { result in
            XCTFail("Expected no result after task cancel")
        }
        
        task.cancel()
        fallbackLoader.complete()
        primaryLoader.complete()
    }
  
    private func makeSUT(primaryLoader: ImageLoaderStub, fallbackLoader: ImageLoaderStub) -> FeedImageLoader {
        let sut = ImageLoaderWithFallbackComposit(
            primaryLoader: primaryLoader,
            fallbackLoader: fallbackLoader
        )
        
        trackMemoryLeaks(sut)
        
        return sut
    }
    
    func expect(sut: FeedImageLoader, toLoadResult expectedResult: FeedImageLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load to complete")
        let url = anyURL()
        
        _ = sut.loadImage(with: url) { result in
            switch (result, expectedResult) {
            case (.success(let data), .success(let expectedData)):
                XCTAssertEqual(data, expectedData)
                
            case (.failure(let error), .failure(let expectedError)):
                XCTAssertEqual((error as NSError), (expectedError as NSError))
            default:
                XCTFail("Expected \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}

fileprivate class ImageLoaderStub: FeedImageLoader {
    private let stub: FeedImageLoader.Result
    private var completion: ((FeedImageLoader.Result) -> Void)?
    private let autoComplete: Bool
    
    init(stub: FeedImageLoader.Result, autoComplete: Bool = true) {
        self.stub = stub
        self.autoComplete = autoComplete
    }
    
    func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = CancellableTask()
        
        if autoComplete {
            completion(stub)
        } else {
            self.completion = completion
        }
        
        return task
    }
    
    func complete() {
        self.completion?(stub)
    }
}
