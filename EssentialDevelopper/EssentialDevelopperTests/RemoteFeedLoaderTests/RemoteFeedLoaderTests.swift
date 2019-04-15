//
//  RemoteFeedLoaderTests.swift
//  EssentialDevelopperTests
//
//  Created by Andre Kvashuk on 4/15/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDevelopper

class RemoteFeedLoaderTests: XCTestCase {
    
    class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var error: Swift.Error?
        
        func get(from url: URL, completion: @escaping (Error?) -> ()) {
            if let error = error {
                completion(error)
            }
            
            requestedURLs.append(url)
        }
    }
    
    func test_init() {
        let (_, client) = makeSUT()
      XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromUrl() {
        let url = URL(string: "http://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs.first, url)
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var expectedError: RemoteFeedLoader.Error?
    
        client.error = NSError(domain: "Test", code: -1, userInfo: nil)
        
        sut.load { error in
            expectedError = error
        }
        XCTAssertEqual(expectedError, RemoteFeedLoader.Error.connectivity)
    }
    
    func test_loadingTwice_RequestDataTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func makeSUT(url: URL = anyURL()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut, client)
    }

}

//MARK: Helpers
func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

