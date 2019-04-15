//
//  RemoteFeedLoaderTests.swift
//  EssentialDevelopperTests
//
//  Created by Andre Kvashuk on 4/15/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest

class HTTPClient {
    var requestedURLs = [URL]()
    
    func load(url: URL) {
        requestedURLs.append(url)
    }
}

class RemoteFeedLoader {
    
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.load(url: url)
    }
    
}

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init() {
        let client = HTTPClient()
        _ = RemoteFeedLoader(url: anyURL(), client: client)
        
        XCTAssertNil(client.requestedURLs.first)
    }
    
    func test_requestsDataFromUrl() {
        let url = URL(string: "http://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs.first, url)
    }
    
    func test_loadingTwiceRequestDataTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs.count, 2)
    }
    
    func makeSUT(url: URL = anyURL()) -> (sut: RemoteFeedLoader, client: HTTPClient) {
        let client = HTTPClient()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut, client)
    }
    //MARK: Helpers
    func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}


