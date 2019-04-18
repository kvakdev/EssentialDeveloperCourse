//
//  URLSessionHTTPClientTests.swift
//  EssentialDevelopperTests
//
//  Created by Andre Kvashuk on 4/17/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDevelopper

protocol HTTPSession {
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask
}

protocol HTTPSessionTask {
    func resume()
}

class URLSessionHTTPClient {
    let session: HTTPSession
    
    init(session: HTTPSession) {
        self.session = session
    }
    
    func load(url: URL, completion: @escaping (HTTPClientResult) -> ()) {
        self.session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
//            else {
//                completion(.success(response as HTTPURLResponse, data))
//            }
        }).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    func test_resumeCount_isInvoked() {
        let url = anyURL()
        let urlSession = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: urlSession)
        let task = URLSesisonDataTaskSpy()
        
        urlSession.stub(url: url, task: task, error: nil)
        sut.load(url: url) { _ in }
        
        XCTAssertEqual(task.resumeCount, 1)
    }
    
    func test_load_deliversErrorOnStubbedError() {
        let url = anyURL()
        let urlSession = URLSessionSpy()
        let sut = URLSessionHTTPClient(session: urlSession)
        let error = NSError(domain: "Test", code: -1, userInfo: nil)
        let exp = expectation(description: "waiting for load to end with error")
        
        urlSession.stub(url: url, error: error)
        
        sut.load(url: url) { result in
            switch result {
                case let .failure(receivedError as NSError):
                    XCTAssertEqual(error, receivedError)
                default:
                    XCTFail("expected error here, got \(result)")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    private class URLSessionSpy: HTTPSession {
        var requestedURL: URL?
        
        private var stubs = [URL: Stub]()
        
        private struct Stub {
            var task: HTTPSessionTask
            var error: Error?
        }
        
        func stub(url: URL, task: HTTPSessionTask = URLSesisonDataTaskSpy(), error: Error?) {
            self.stubs[url] = Stub(task: task, error: error)
        }
        
        func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> HTTPSessionTask {
            requestedURL = url
            
            guard let stub = stubs[url] else {
                fatalError("couldn't find stub for \(url.absoluteString)")
            }
            
            completionHandler(nil, nil, stub.error)
            
            return stub.task
        }
    }
    
    private class URLSesisonDataTaskSpy: HTTPSessionTask {
        var resumeCount = 0
        
        func resume() {
            resumeCount += 1
        }
    }
    
    private class FakeURLDataTask: HTTPSessionTask {
        func resume() {}
    }
}
