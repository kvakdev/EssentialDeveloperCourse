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
        let error = NSError(domain: "Test", code: -1, userInfo: nil)
        
        expect(sut: sut, toCompleteWith: [.failure(.connectivity)], when: {
            client.complete(with: error)
        })
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
            expect(sut: sut, toCompleteWith: [.failure(.invalidData)], when: {
                client.completeWith(statusCode: code, at: index)
            })
        }
    }
    
    func test_deliversErrorOnInvalidData() {
        let (sut, client) = makeSUT()
        let data = Data("invalid data".utf8)
        
        expect(sut: sut, toCompleteWith: [.failure(.invalidData)]) {
            client.completeWith(statusCode: 200, data: data)
        }
    }
    
    func expect(sut: RemoteFeedLoader, toCompleteWith expectedResult: [RemoteFeedLoader.Result], when action: (() -> ())) {
        
        var receivedResult = [RemoteFeedLoader.Result]()
        
        sut.load { result in
            receivedResult.append(result)
        }
        
        action()
        
        XCTAssertEqual(receivedResult, expectedResult)
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
        
        func completeWith(statusCode: Int, data: Data = Data(), at index: Int = 0) {
            let httpResponse = HTTPURLResponse(
                url: requestedURLs[index],
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: nil)!
            
            self.messages[index].completion(.success(httpResponse, data))
        }
    }
}

//MARK: Helpers
func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}

