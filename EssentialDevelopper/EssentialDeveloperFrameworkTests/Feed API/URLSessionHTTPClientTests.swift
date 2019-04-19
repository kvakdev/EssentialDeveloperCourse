//
//  URLSessionHTTPClientTests.swift
//  EssentialDevelopperTests
//
//  Created by Andre Kvashuk on 4/17/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework


class URLSessionHTTPClientTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        URLProtocolStub.startInterceptingRequests()
    }
    
    override func tearDown() {
        super.tearDown()
        
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
        
        makeSUT().get(from: url) { _ in }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_getFromUrl_deliversErrorOnRequestError() {
        let error = NSError(domain: "Test", code: -1, userInfo: nil)
        
        let receivedError = errorFor(data: nil, response: nil, error: error)
        
        XCTAssertEqual(error, receivedError as NSError?)
    }
    
    func test_load_returnsSuccessOnNilData() {
        let response = anyHTTPURLResponse()
        let emptyData = Data()
        
        let receivedValues = resultValuesFor(data: nil, response: response, error: nil)
        
        XCTAssertEqual(response.url, receivedValues?.response.url)
        XCTAssertEqual(response.statusCode, receivedValues?.response.statusCode)
        XCTAssertEqual(emptyData, receivedValues?.data)
    }
    
    func test_getFromUrl_returnsErrorOnAllInvalidCases() {
        XCTAssertNotNil(errorFor(data: nil, response: nil, error: nil))
        XCTAssertNotNil(errorFor(data: nil, response: nonHTTPURLResponse(), error: nil))
        XCTAssertNotNil(errorFor(data: nil, response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(errorFor(data: nil, response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(errorFor(data: anyData(), response: anyHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(errorFor(data: anyData(), response: nonHTTPURLResponse(), error: anyNSError()))
        XCTAssertNotNil(errorFor(data: anyData(), response: nil, error: nil))
        XCTAssertNotNil(errorFor(data: anyData(), response: nonHTTPURLResponse(), error: nil))
    }
 
    func test_getFromURL_returnsSuccessOnValidResponseAndData() {
        let response = anyHTTPURLResponse()
        let data = anyData()
        
        let receivedValues = resultValuesFor(data: data, response: response, error: nil)
        
        XCTAssertEqual(response.url, receivedValues?.response.url)
        XCTAssertEqual(response.statusCode, receivedValues?.response.statusCode)
        XCTAssertEqual(data, receivedValues?.data)
    }
    
    func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func anyHTTPURLResponse() -> HTTPURLResponse {
        return HTTPURLResponse(url: anyURL(), statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    func errorFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> Error? {
        
        let result = resultFor(data: data, response: response, error: error)
        
        switch result {
        case .failure(let receivedError):
            return receivedError
        default:
            return nil
        }
    }
    
    func resultValuesFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> (response: HTTPURLResponse, data: Data)? {
        
        let result = resultFor(data: data, response: response, error: error, file: file, line: line)
        
        switch result {
        case .success(let receivedResponse, let receivedData):
            return (receivedResponse, receivedData)
        default:
            XCTFail("expected result, got \(result) instead")
        }
        return nil
    }
    
    func resultFor(data: Data?, response: URLResponse?, error: Error?, file: StaticString = #file, line: UInt = #line) -> HTTPClientResult {
        URLProtocolStub.stub(data: data, response: response, error: error)
        let exp = expectation(description: "waiting for load to end with error")
        var receivedResult: HTTPClientResult!
        
        makeSUT().get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        
        return receivedResult
    }
    
    func makeSUT() -> HTTPClient {
        let sut = URLSessionHTTPClient()
        
        trackMemoryLeaks(sut)
        
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
        
        private typealias ObserverRequestBlock = (URLRequest) -> Void
        private static var observeRequestBlock: ObserverRequestBlock?
        
        struct Stub {
            var data: Data?
            var response: URLResponse?
            var error: Error?
        }
        
        public static func stub(data: Data?, response: URLResponse?, error: Error?) {
            stub = Stub(data: data, response: response, error: error)
        }
        
        static func startInterceptingRequests() {
            URLProtocol.registerClass(URLProtocolStub.self)
        }
        
        static func stopInterceptingRequests() {
            URLProtocol.unregisterClass(URLProtocolStub.self)
            stub = nil
            observeRequestBlock = nil
        }
        
        override class func canInit(with request: URLRequest) -> Bool {
            observeRequestBlock?(request)
            
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let data = URLProtocolStub.stub?.data {
                client?.urlProtocol(self, didLoad: data)
            }
            
            if let response = URLProtocolStub.stub?.response {
                client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            
            if let error = URLProtocolStub.stub?.error {
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
