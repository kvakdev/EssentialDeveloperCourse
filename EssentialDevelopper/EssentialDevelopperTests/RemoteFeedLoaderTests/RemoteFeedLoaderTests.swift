//
//  RemoteFeedLoaderTests.swift
//  EssentialDevelopperTests
//
//  Created by Andre Kvashuk on 4/15/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest

class HTTPClient {
    var requestedURL: URL?
    
    func load(url: URL) {
        requestedURL = url
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
        let sut = RemoteFeedLoader(url: anyURL(), client: client)
        
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_requestsDataFromUrl() {
        let client = HTTPClient()
        let url = anyURL()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURL, url)
    }
    
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}
