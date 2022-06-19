//
//  URLSessionHTTPClientTests.swift
//  EssentialDevelopperTests
//
//  Created by Andre Kvashuk on 4/17/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed


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
        
        let receivedError = errorFor((data: nil, response: nil, error: error))
        
        XCTAssertEqual(error.domain, (receivedError as? NSError)?.domain)
        XCTAssertEqual(error.code, (receivedError as? NSError)?.code)
        XCTAssertEqual(error.localizedDescription, (receivedError as? NSError)?.localizedDescription)
    }
    
    func test_load_returnsSuccessOnNilData() {
        let response = anyHTTPURLResponse()
        let emptyData = Data()
        
        let receivedValues = resultValuesFor((data: nil, response: response, error: nil))
        
        XCTAssertEqual(response.url, receivedValues?.response.url)
        XCTAssertEqual(response.statusCode, receivedValues?.response.statusCode)
        XCTAssertEqual(emptyData, receivedValues?.data)
    }
    
    func test_getFromUrl_returnsErrorOnAllInvalidCases() {
        XCTAssertNotNil(errorFor((data: nil, response: nil, error: nil)))
        XCTAssertNotNil(errorFor((data: nil, response: nonHTTPURLResponse(), error: nil)))
        XCTAssertNotNil(errorFor((data: nil, response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(errorFor((data: nil, response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(errorFor((data: anyData(), response: anyHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(errorFor((data: anyData(), response: nonHTTPURLResponse(), error: anyNSError())))
        XCTAssertNotNil(errorFor((data: anyData(), response: nil, error: nil)))
        XCTAssertNotNil(errorFor((data: anyData(), response: nonHTTPURLResponse(), error: nil)))
    }
    
    func test_cancellingTask_returnsError() {
        let error = errorFor((data: anyData(), response: anyHTTPURLResponse(), error: nil), taskHandler: { task in task.cancel() })
        
        XCTAssertEqual((error as? NSError)?.code, URLError.cancelled.rawValue)
    }
 
    func test_getFromURL_returnsSuccessOnValidResponseAndData() {
        let response = anyHTTPURLResponse()
        let data = anyData()
        
        let receivedValues = resultValuesFor((data: data, response: response, error: nil))
        
        XCTAssertEqual(response.url, receivedValues?.response.url)
        XCTAssertEqual(response.statusCode, receivedValues?.response.statusCode)
        XCTAssertEqual(data, receivedValues?.data)
    }
    
    func nonHTTPURLResponse() -> URLResponse {
        return URLResponse(url: anyURL(), mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
    }
    
    func errorFor(_ values: (data: Data?, response: URLResponse?, error: Error?), taskHandler: Closure<HTTPClientTask>? = nil, file: StaticString = #file, line: UInt = #line) -> Error? {
        
        let result = resultFor(values, taskHandler: taskHandler, file: file, line: line)
        
        switch result {
        case .failure(let receivedError):
            return receivedError
        default:
            return nil
        }
    }
    
    func resultValuesFor(_ values: (data: Data?, response: URLResponse?, error: Error?), file: StaticString = #file, line: UInt = #line) -> (response: HTTPURLResponse, data: Data)? {
        
        let result = resultFor(values, file: file, line: line)
        
        switch result {
        case .success((let receivedResponse, let receivedData)):
            return (receivedResponse, receivedData)
        default:
            XCTFail("expected result, got \(result) instead")
        }
        return nil
    }
    
    func resultFor(_ values: (data: Data?, response: URLResponse?, error: Error?)?, taskHandler: Closure<HTTPClientTask>? = nil, file: StaticString = #file, line: UInt = #line) -> HTTPClient.Result {
        
        values.map { URLProtocolStub.stub(data: $0, response: $1, error: $2) }
        
        let exp = expectation(description: "waiting for load to end with error")
        var receivedResult: HTTPClient.Result!
        
        let sut = makeSUT(file: file, line: line)
            
        let task = sut.get(from: anyURL()) { result in
            receivedResult = result
            exp.fulfill()
        }
        
        taskHandler?(task)
        
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
}

// MARK: -
private extension URLSessionHTTPClientTests {
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> HTTPClient {
        let sut = URLSessionHTTPClient()
        
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    func anyNSError() -> NSError {
        return NSError(domain: "TestHTTPClientError", code: 1, userInfo: nil)
    }
}
// MARK: -
private extension URLSessionHTTPClientTests {
    class URLProtocolStub: URLProtocol {
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
            return true
        }
        
        override class func canonicalRequest(for request: URLRequest) -> URLRequest {
            return request
        }
        
        override func startLoading() {
            if let requestObserver = Self.observeRequestBlock {
                client?.urlProtocolDidFinishLoading(self)
                return requestObserver(self.request)
            }
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
