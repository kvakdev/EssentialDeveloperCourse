//
//  RemoteFeedLoaderTests.swift
//  EssentialDevelopperTests
//
//  Created by Andre Kvashuk on 4/15/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDevelopper

class RemoteFeedLoaderTests: XCTestCase {
    
    func test_init() {
        let (_, client) = makeSUT()
      XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromUrl() {
        let url = URL(string: "http://a-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs.first, url)
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        var expectedErrors = [RemoteFeedLoader.Error]()
    
        let error = NSError(domain: "Test", code: -1, userInfo: nil)
        
        sut.load { expectedErrors.append($0) }
        
        client.complete(with: error)
        
        XCTAssertEqual(expectedErrors, [.connectivity])
    }
    
    func test_loadingTwice_RequestDataTwice() {
        let url = anyURL()
        let (sut, client) = makeSUT(url: url)
        
        sut.load() { _ in }
        sut.load() { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnNon200StatusCode() {
        let (sut, client) = makeSUT()
        let samples = [199, 300, 400, 404, 500]
        
        samples.enumerated().forEach { index, code in
            var expectedErrors = [RemoteFeedLoader.Error]()
            
            sut.load { error in
                expectedErrors.append(error)
            }
            
            client.completeWith(statusCode: code, at: index)
            
            XCTAssertEqual(expectedErrors, [.invalidData])
        }
    }
    
    func makeSUT(url: URL = anyURL()) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    class HTTPClientSpy: HTTPClient {
        var messages = [(url: URL, completion:(HTTPClientResult) -> ())]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> ()) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            self.messages[index].completion(.failure(error))
        }
        
        func completeWith(statusCode: Int, at index: Int = 0) {
            let httpResponse = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil)!
            self.messages[index].completion(.success(httpResponse))
        }
    }
}

//MARK: Helpers
func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

