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
        
        URLProtocolStub.stub(url: url, error: error)
        
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
        
        public static var stubs = [URL: Stub]()
        
        struct Stub {
            var error: Error?
        }
        
        public static func stub(url: URL, error: Error?) {
            URLProtocolStub.stubs[url] = Stub(error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocolStub.stubs = [:]
            URLProtocol.unregisterClass(URLProtocolStub.self)
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            guard let url = request.url else { return false }
            
            return URLProtocolStub.stubs[url] != nil
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            guard let url = request.url else { return }
            
            if let error = URLProtocolStub.stubs[url]?.error {
                client?.urlProtocol(self, didFailWithError: error)
            }
            
            client?.urlProtocolDidFinishLoading(self)
        }
        
        override func stopLoading() {}
    }
}
