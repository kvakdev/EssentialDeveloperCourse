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
    
    func test_load_deliversErrorOnStubbedError() {
        URLProtocolStub.startInterceptingRequests()
        let url = anyURL()
        let sut = URLSessionHTTPClient()
        
        let error = NSError(domain: "Test", code: -1, userInfo: nil)
        let exp = expectation(description: "waiting for load to end with error")
        
        URLProtocolStub.stub(data: nil, response: nil, error: error)
        
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
        URLProtocolStub.stopInterceptingRequests()
    }
    
    private class URLProtocolStub: URLProtocol {
        var requestedURL: URL?
        
        public static var stub: Stub?
        
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
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
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
    }
}
