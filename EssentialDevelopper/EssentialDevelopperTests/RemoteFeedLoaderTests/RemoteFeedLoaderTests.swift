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
        let client = HTTPClient()
        let url = anyURL()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs.first, url)
    }
    
    func test_loadingTwiceRequestDataTwice() {
        let client = HTTPClient()
        let url = anyURL()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs.count, 2)
    }
    
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
