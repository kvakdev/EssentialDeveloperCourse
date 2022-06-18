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

struct HTTPTask: HTTPClientTask {
    func cancel() {}
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
        
        let httpTask = self.client.get(from: url) { result in
            
            imageLoadTask.complete(with: result
                .mapError { _ in ImageLoadingError.connection }
                .flatMap { (response, data) in
                    let isValidResponse = response.statusCode == 200 && !data.isEmpty
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
        let clientSpy = HTTPClientSpy()
        let _ = RemoteFeedImageLoader(client: clientSpy)
        
        XCTAssertTrue(clientSpy.messages.isEmpty)
    }
    
    func test_cancelTask_deliversNoResult() {
        let clientSpy = HTTPClientSpy()
        let sut = RemoteFeedImageLoader(client: clientSpy)
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
        let clientSpy = HTTPClientSpy()
        let sut = RemoteFeedImageLoader(client: clientSpy)
        let url = anyURL()
        let expectedError = anyNSError()
        
        let task = sut.loadImage(with: url) { result in
            XCTFail("Expected no complete, but it got called instead")
        }
        
        task.cancel()
        clientSpy.completeWith(expectedError)
    }
    
    func test_load_deliversErrorOnEmptyData() {
        let expectedError = ImageLoadingError.invalidData
        let httpResult = HTTPClient.Result.success((anyHTTPURLResponse(), Data()))
        
        expectToLoad(.failure(expectedError), for: httpResult)
    }
    
    func test_load_deliversErrorOnInvalidStatusCode() {
        let validData = Data(repeating: 1, count: 1)
        let invalidResponse = HTTPURLResponse(url: anyURL(), statusCode: 404, httpVersion: nil, headerFields: nil)!
        
        expectToLoad(.failure(ImageLoadingError.invalidData), for: .success((invalidResponse, validData)))
    }
    
    func test_load_deliversDataReceivedInTheResultOfHTTPClient() {
        let data = Data(repeating: 1, count: 1)
        let validResponse = anyHTTPURLResponse()
        
        expectToLoad(.success(data), for: .success((validResponse, data)))
    }
    
    private func expectToLoad(_ expectedResult: FeedImageLoader.ImageLoadResult, for httpResult: HTTPClient.Result, file: StaticString = #file, line: UInt = #line) {
        let clientSpy = HTTPClientSpy()
        let sut = RemoteFeedImageLoader(client: clientSpy)
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
    
    private class HTTPClientSpy: HTTPClient {
        var messages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url: url, completion: completion))
            return HTTPTask()
        }
        
        func completeSuccessfully(data: Data = Data(), response: HTTPURLResponse = anyHTTPURLResponse(), at index: Int = 0) {
            messages[index].completion(.success((response, data)))
        }
        
        func completeWith(_ error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
        
        func complete(with result: HTTPClient.Result, at index: Int) {
            messages[index].completion(result)
        }
    }
}
