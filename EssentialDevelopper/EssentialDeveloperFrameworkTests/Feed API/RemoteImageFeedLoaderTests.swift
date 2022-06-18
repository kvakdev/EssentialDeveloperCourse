//
//  RemoteImageFeedLoaderTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/18/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed

extension DispatchWorkItem: FeedImageDataLoaderTask {}

class RemoteFeedImageLoader: FeedImageLoader {
    let client: HTTPClient
    private var task: DispatchWorkItem?
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImage(with url: URL, completion: @escaping (ImageLoadResult) -> Void) -> FeedImageDataLoaderTask {
        
        let task = DispatchWorkItem {
            self.client.get(from: url) { result in
                switch result {
                case .success((let response, let data)):
                    guard response.statusCode == 200 else { return }
                    
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
        task.perform()
        
        return task
    }
}

class RemoteImageFeedLoaderTests: XCTestCase {
    
    func test_init_hasNoSideEffects() {
        let clientSpy = HTTPClientSpy()
        let _ = RemoteFeedImageLoader(client: clientSpy)
        
        XCTAssertTrue(clientSpy.completions.isEmpty)
    }
    
    private class HTTPClientSpy: HTTPClient {
        func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
            
        }
        
        var completions: [(url: URL, completion: HTTPClient.Result)] = []
    }
}
