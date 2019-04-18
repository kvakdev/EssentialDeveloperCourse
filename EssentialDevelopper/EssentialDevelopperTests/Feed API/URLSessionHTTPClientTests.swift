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
    
    struct InvalidRepresentationError: Error {}
    
    func load(url: URL, completion: @escaping (HTTPClientResult) -> ()) {
        self.session.dataTask(with: url, completionHandler: { data, response, error in
            
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse, !data.isEmpty {
                completion(.success(response, data))
            } else {
                completion(.failure(InvalidRepresentationError()))
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
    
    func test_getFromUrl_deliversErrorOnRequestError() {
        let error = NSError(domain: "Test", code: -1, userInfo: nil)
        
        let receivedError = errorFor(data: nil, response: nil, error: error)
        
        XCTAssertEqual(error, receivedError as NSError?)
    }
    
    func test_getFromUrl_returnErrorOnAllInvalidCases() {
        XCTAssertNotNil(errorFor(data: nil, response: anyHTTPURLResponse(), error: nil))
        XCTAssertNotNil(errorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(errorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(errorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(errorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(errorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(errorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(errorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(errorFor(data: anyData(), response: anyHTTPURLResponse(), error: nil))
        XCTAssertNotNil(errorFor(data: nil, response: nil, error: nil))
    }
    
    func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func errorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = expectation(description: "waiting for load to end with error")
        var receivedError: Error?
        
        makeSUT().load(url: anyURL()) { result in
            switch result {
            case let .failure(error):
                receivedError = error
            default:
                XCTFail("expected error here, got \(result)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedError
    }
    
    func makeSUT() -> URLSessionHTTPClient {
        let sut = URLSessionHTTPClient()
        
        return sut
    }
    
    func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "TestHTTPClientError", code: 1, userInfo: nil)
    }
    
    private class URLProtocolStub: URLProtocol {
        var requestedURL: URL?
        
        public static var stub: Stub?
        
        private typealias ObserverRequestBlock = (URLRequest) -> ()
        private static var observeRequestBlock: ObserverRequestBlock?
        
        struct Stub {
            var data: Data?
            var response: URLResponse?
            var error: Error?
        }
        
        public static func stub(data: Data?, response: URLResponse?, error: Error?) {
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
