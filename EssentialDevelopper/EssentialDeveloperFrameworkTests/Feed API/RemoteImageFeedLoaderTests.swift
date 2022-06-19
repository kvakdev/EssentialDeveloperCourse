//
//  RemoteImageFeedLoaderTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/18/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed

typealias Closure<T> = (T) -> Void
typealias VoidClosure = () -> Void

extension HTTPURLResponse {
    var isOK: Bool { statusCode == 200 }
}

class HTTPTask: HTTPClientTask {
    var cancelCompletion: VoidClosure?
    
    init(cancelCompletion: @escaping VoidClosure) {
        self.cancelCompletion = cancelCompletion
    }
    
    func cancel() {
        cancelCompletion?()
        cancelCompletion = nil
    }
}

class RemoteImageLoadingTask: FeedImageDataLoaderTask {
    var wrapped: HTTPClientTask?
    var completion: Closure<FeedImageLoader.ImageLoadResult>?
    
    init(completion: @escaping Closure<FeedImageLoader.ImageLoadResult>) {
        self.completion = completion
    }
    
    func complete(with result: FeedImageLoader.ImageLoadResult) {
        completion?(result)
    }
    
    func cancel() {
        completion = nil
        wrapped?.cancel()
    }
}

class RemoteFeedImageLoader: FeedImageLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImage(with url: URL, completion: @escaping (ImageLoadResult) -> Void) -> FeedImageDataLoaderTask {
        let imageLoadTask = RemoteImageLoadingTask(completion: completion)
        
        let httpTask = self.client.get(from: url) { [weak self] result in
            guard let self = self else { return }
            
            imageLoadTask.complete(with: result
                .mapError { _ in ImageLoadingError.connection }
                .flatMap { (response, data) in
                    let isValidResponse = response.isOK && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(ImageLoadingError.invalidData)
            })
        }
        imageLoadTask.wrapped = httpTask
        
        return imageLoadTask
    }
}

enum ImageLoadingError: Error {
    case invalidData
    case connection
}

class RemoteImageFeedLoaderTests: XCTestCase {
    
    func test_init_hasNoSideEffects() {
        let (_, clientSpy) = makeSUT()
        
        XCTAssertTrue(clientSpy.messages.isEmpty)
    }
    
    func test_load_loadsCorrectURLFromHTTPClient() {
        let (sut, clientSpy) = makeSUT()
        let url = anyURL()
        let secondURL = URL(string: "http://other-url.com")!
        _ = sut.loadImage(with: url) { result in }
        
        XCTAssertEqual(clientSpy.messages.count, 1)
        XCTAssertEqual(clientSpy.messages[0].url, url)
        
        _ = sut.loadImage(with: secondURL) { _ in }
        
        XCTAssertEqual(clientSpy.messages.count, 2)
        XCTAssertEqual(clientSpy.messages[1].url, secondURL)
    }
    
    func test_loadFailure_deliversConnectionErrorOnAnyError() {
        expectToLoad(.failure(ImageLoadingError.connection), for: .failure(anyNSError()))
    }
    
    func test_load_deliversNoErrorOnCancelTask() {
        let (sut, clientSpy) = makeSUT()
        let url = anyURL()
        let expectedError = anyNSError()
        
        let task = sut.loadImage(with: url) { result in
            XCTFail("Expected no complete, but it got called instead")
        }
        
        task.cancel()
        clientSpy.complete(with: expectedError, at: 0)
        clientSpy.completeWith(statusCode: 200)
    }
    
    func test_cancelImageLoadTask_cancelsHTTPTask() {
        let (sut, clientSpy) = makeSUT()
        let url = anyURL()
        
        let task = sut.loadImage(with: url) { result in }
        task.cancel()
        
        XCTAssertEqual(clientSpy.cancelledURLs, [url])
    }
    
    func test_load_deliversErrorOnEmptyDataAndValidResponse() {
        let expectedError = ImageLoadingError.invalidData
        let httpResult = HTTPClient.Result.success((anyHTTPURLResponse(), Data()))
        
        expectToLoad(.failure(expectedError), for: httpResult)
    }
    
    func test_load_deliversErrorOnInvalidStatusCode() {
        let invalidStatusCodes = [199, 201, 404, 500]
        
        invalidStatusCodes.forEach { code in
            let invalidResponse = HTTPURLResponse(url: anyURL(), statusCode: code, httpVersion: nil, headerFields: nil)!
            
            expectToLoad(.failure(ImageLoadingError.invalidData),
                         for: .success((invalidResponse, anyData())))
        }
    }
    
    func test_load_deliversDataReceivedInTheResultOfHTTPClient() {
        let data = anyData()
        let validResponse = anyHTTPURLResponse()
        
        expectToLoad(.success(data), for: .success((validResponse, data)))
    }
    
    func test_load_deliversNoResultAfterInstanceHasBeenDeallocated() {
        var (sut, clientSpy): (RemoteFeedImageLoader?, HTTPClientSpy) = makeSUT()
        
        _ = sut?.loadImage(with: anyURL(), completion: { _ in
            XCTFail("Expected no completion after instance deallocation")
        })
        
        sut = nil
        clientSpy.completeWith(statusCode: 200)
    }
    
    private func expectToLoad(_ expectedResult: FeedImageLoader.ImageLoadResult, for httpResult: HTTPClient.Result, file: StaticString = #file, line: UInt = #line) {
        let (sut, clientSpy) = makeSUT()
        let url = anyURL()
        let exp = expectation(description: "wait for load to complete")
        
        _ = sut.loadImage(with: url) { result in
            switch (result, expectedResult) {
            case (.success(let receivedData), .success(let expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case (.failure(let receivedError), .failure(let expectedError)):
                XCTAssertEqual((receivedError as? ImageLoadingError), (expectedError as? ImageLoadingError), file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult) on got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        clientSpy.complete(with: httpResult, at: 0)
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (RemoteFeedImageLoader, HTTPClientSpy) {
        let clientSpy = HTTPClientSpy()
        let sut = RemoteFeedImageLoader(client: clientSpy)
        
        trackMemoryLeaks(clientSpy, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, clientSpy)
    }
}

