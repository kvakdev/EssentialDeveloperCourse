//
//  URLSessionHTTPClientTests.swift
//  EssentialDevelopperTests
//
//  Created by Andre Kvashuk on 4/17/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDevelopper


class URLSessionHTTPClient {
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func load(url: URL, completion: @escaping (HTTPClientResult) -> ()) {
        self.session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            }
        }).resume()
    }
}

class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        URLProtocolStub.stopInterceptingRequests()
    }
    
    func test_getURL_makesGETRequestWithGivenURL() {
        let url = anyURL()
        let exp = expectation(description: "waiting for load to end with error")
        
        URLProtocolStub.observeRequest { request in
            XCTAssertEqual(url, request.url)
            XCTAssertEqual(request.httpMethod, "GET")
            
            exp.fulfill()
        }
        
        makeSUT().load(url: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_deliversErrorOnStubbedError() {
        let error = NSError(domain: "Test", code: -1, userInfo: nil)
        let exp = expectation(description: "waiting for load to end with error")
        
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
        makeSUT().load(url: anyURL()) { result in
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
    
    func makeSUT() -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        
        return sut
    }
    
    private class URLProtocolStub: URLProtocol {
        var requestedURL: URL?
        
        public static var stub: Stub?
        
        private typealias ObserverRequestBlock = (URLRequest) -> ()
        private static var observeRequestBlock: ObserverRequestBlock?
        
        struct Stub {
            var data: Data?
            var response: HTTPURLResponse?
            var error: Error?
        }
        
        public static func stub(data: Data?, response: HTTPURLResponse?, error: Error?) {
            URLProtocolStub.stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocolStub.stub = nil
            URLProtocolStub.observeRequestBlock = nil
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            URLProtocolStub.observeRequestBlock?(request)
            
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            let stub = URLProtocolStub.stub
            
            if let data = stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = stub?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
        
        static func observeRequest(completion: @escaping (URLRequest) -> ()) {
            URLProtocolStub.observeRequestBlock = completion
        }
    }
}
