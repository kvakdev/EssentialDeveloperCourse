//
//  URLSessionHTTPClientTests.swift
//  EssentialDevelopperTests
//
//  Created by Andre Kvashuk on 4/17/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest

class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession) {
        self.session = session
    }
    
    func load(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        self.session.dataTask(with: url, completionHandler: { _,_,_ in })
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_load_withTheGivenUrl() {
        let url = anyURL()
        let urlSession = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: urlSession)
        
        sut.load(url: url, completion: { _,_,_ in })
        
        XCTAssertEqual(urlSession.requestedURL, url)
    }
    
    
    private class URLSessionSpy: URLSession {
        var requestedURL: URL?
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURL = url
            
            return FakeURLDataTask()
        }
    }
    
    private class FakeURLDataTask: URLSessionDataTask {
        
    }
}
