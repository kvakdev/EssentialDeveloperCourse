//
//  ImageLoaderWithFallbackCompositTests.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/23/22.
//

import XCTest
import EssentialFeed

class TaskWrapper: FeedImageDataLoaderTask {
    func cancel() {
        
    }
}

class ImageLoaderWithFallbackComposit: FeedImageLoader {
    let primaryLoader: FeedImageLoader
    
    init(primaryLoader: FeedImageLoader) {
        self.primaryLoader = primaryLoader
    }
    
    func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = primaryLoader.loadImage(with: url, completion: completion)
        
        return task
    }
}

class ImageLoaderStub: FeedImageLoader {
    private let stub: FeedImageLoader.Result
    
    init(stub: FeedImageLoader.Result) {
        self.stub = stub
    }
    
    func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        completion(stub)
        
        return TaskWrapper()
    }
}

class ImageLoaderWithFallbackCompositTests: XCTestCase {
    
    func test_primaryloader_deliversImageDataInPrimarySucceeds() {
        let expectedData = Data("data".utf8)
        let primaryLoader = ImageLoaderStub(stub: .success(expectedData))
        let sut = ImageLoaderWithFallbackComposit(primaryLoader: primaryLoader)
        
        expect(sut: sut, toLoadResult: .success(expectedData))
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
