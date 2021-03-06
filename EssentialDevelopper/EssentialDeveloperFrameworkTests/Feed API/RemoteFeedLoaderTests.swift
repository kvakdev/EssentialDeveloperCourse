//
//  RemoteFeedLoaderTests.swift
//  EssentialDevelopperTests
//
//  Created by Andre Kvashuk on 4/15/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

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
        
        expect(sut: sut, toCompleteWith: failure(.connectivity), when: {
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
        
        samples.enumerated().forEach { item in
            expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
                client.completeWith(statusCode: item.element, at: item.offset)
            })
        }
    }
    
    func test_load_deliversErrorOnInvalidData() {
        let (sut, client) = makeSUT()
        let data = Data("invalid data".utf8)
        
        expect(sut: sut, toCompleteWith: failure(.invalidData), when: {
            
            client.completeWith(statusCode: 200, data: data)
        })
    }
    
    func test_load_deliversEmptyArrayOnEmptyJSONData() {
        let (sut, client) = makeSUT()
        let emptyListJSON = Data("{\"items\": []}".utf8)
        
        expect(sut: sut, toCompleteWith: success([]), when: {
            client.completeWith(statusCode: 200, data: emptyListJSON)
        })
    }
    
    func test_load_deliversFeedItemsOnValidJSONObject() {
        let (sut, client) = makeSUT()
        
        let item1 = makeItem()
        let item2 = makeItem()
        
        let items = [item1.item, item2.item]
        
        let itemsJSON = ["items": [item1.json, item2.json]]
        
        expect(sut: sut, toCompleteWith: success(items), when: {
            let json = try! JSONSerialization.data(withJSONObject: itemsJSON)
            client.completeWith(statusCode: 200, data: json)
        })
    }
    
    func test_load_doesNotDeliverResultsAfterLoaderWasDeallocated() {
        let url = anyURL()
        let client = HTTPClientSpy()
        var sut: RemoteFeedLoader? = RemoteFeedLoader(url: url, client: client)
        var receivedResult = [RemoteFeedLoader.Result]()
        
        sut?.load { receivedResult.append($0) }
        sut = nil
        client.completeWith(statusCode: 200)
        
        XCTAssertTrue(receivedResult.isEmpty)
    }
    
    func expect(sut: RemoteFeedLoader, toCompleteWith expectedResult: RemoteFeedLoader.Result, when action: (() -> ()), file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "Wait for load reaults to complete")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
                
            case let (.failure(error as RemoteFeedLoader.Error), .failure(expectedError as RemoteFeedLoader.Error)):
                XCTAssertEqual(error, expectedError, file: file, line: line)
            case let (.success(items), .success(expectedItems)):
                XCTAssertEqual(items, expectedItems, file: file, line: line)
            default:
                XCTFail("expected \(expectedResult), but received \(receivedResult)")
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func success(_ items: [FeedItem]) -> RemoteFeedLoader.Result {
        return RemoteFeedLoader.Result.success(items)
    }
    
    func failure(_ error: RemoteFeedLoader.Error) -> RemoteFeedLoader.Result {
        return RemoteFeedLoader.Result.failure(error)
    }
    
    func makeSUT(url: URL = anyURL(), file: StaticString = #file, line: UInt = #line) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(client, file: file, line: line)
        
        return (sut, client)
    }
    
    func makeItem(id: UUID = UUID(), description: String? = nil, location: String? = nil, image: URL = anyURL()) -> (item: FeedItem, json: [String: Any]) {
        let feedItem = FeedItem(id: id, description: description, location: location, imageUrl: image)
        
        let json = dictFrom(item: feedItem)
        
        return (feedItem, json)
    }
    
    private func dictFrom(item: FeedItem) -> [String: Any] {
        
        return [
            "id"            : item.id.uuidString,
            "image"         : item.imageURL.absoluteString,
            "location"      : item.location,
            "description"   : item.description
            ]
            .reduce(into: [String: Any]()) { result, dict in
                if let value = dict.value {
                    result[dict.key] = value
                }
        }
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

