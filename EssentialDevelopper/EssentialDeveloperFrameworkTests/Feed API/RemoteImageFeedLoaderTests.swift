//
//  RemoteImageFeedLoaderTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/18/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed

struct HTTPTask: HTTPClientTask {
    func cancel() {
    
    }
}

struct RemoteImageLoadingTask: FeedImageDataLoaderTask {
    let wrapped: HTTPClientTask
    
    init(wrapped: HTTPClientTask) {
        self.wrapped = wrapped
    }
    
    func cancel() {
        wrapped.cancel()
    }
}

class RemoteFeedImageLoader: FeedImageLoader {
    let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImage(with url: URL, completion: @escaping (ImageLoadResult) -> Void) -> FeedImageDataLoaderTask {
        
        let httpTask = self.client.get(from: url) { result in
            
        }
        
        return RemoteImageLoadingTask(wrapped: httpTask)
    }
    
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
    
    private class HTTPClientSpy: HTTPClient {
        
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
            messages.append((url: url, completion: completion))
            return HTTPTask()
        }
        
        var messages: [(url: URL, completion: (HTTPClient.Result) -> Void)] = []
        
        func completeSuccessfully(at index: Int = 0) {
            let result = HTTPClient.Result {
                (anyHTTPURLResponse(), Data())
            }
            let message = messages[index]
            message.completion(result)
        }
    }
}
