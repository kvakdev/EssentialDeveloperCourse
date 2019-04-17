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
    
    func load(url: URL) {
        self.session.dataTask(with: url, completionHandler: { _,_,_ in }).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {

    func test_load_withTheGivenUrl() {
        let url = anyURL()
        let urlSession = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: urlSession)
        let task = URLSesisonDataTaskSpy()
        
        urlSession.stub(url: url, task: task)
        sut.load(url: url)
        
        XCTAssertEqual(urlSession.requestedURL, url)
    }
    
    func test_resumeCount_isInvoked() {
        let url = anyURL()
        let urlSession = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: urlSession)
        let task = URLSesisonDataTaskSpy()
        
        urlSession.stub(url: url, task: task)
        sut.load(url: url)
        
        XCTAssertEqual(task.resumeCount, 1)
    }
    
    private class URLSessionSpy: URLSession {
        var requestedURL: URL?
        
        var stubs = [URL: URLSessionDataTask]()
        
        func stub(url: URL, task: URLSessionDataTask) {
            self.stubs[url] = task
        }
        
        override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
            requestedURL = url
            
            return stubs[url] ?? FakeURLDataTask()
        }
    }
    
    private class URLSesisonDataTaskSpy: URLSessionDataTask {
        var resumeCount = 0
        
        override func resume() {
            resumeCount += 1
        }
    }
    
    private class FakeURLDataTask: URLSessionDataTask {
        override func resume() {}
    }
}
