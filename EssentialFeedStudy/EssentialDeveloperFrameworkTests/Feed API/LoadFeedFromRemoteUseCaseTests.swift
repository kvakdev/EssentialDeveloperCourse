//
//  RemoteFeedLoaderTests.swift
//  EssentialDevelopperTests
//
//  Created by Andre Kvashuk on 4/15/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed

class LoadFeedFromRemoteUseCaseTests: XCTestCase {
    
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
        
        let image1 = makeImage()
        let image2 = makeImage()
        
        let imageFeed = [image1.image, image2.image]
        
        let itemsJSON = ["items": [image1.json, image2.json]]
        
        expect(sut: sut, toCompleteWith: .success(imageFeed), when: {
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
                XCTFail("expected \(expectedResult), but received \(receivedResult)", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func success(_ items: [FeedImage]) -> RemoteFeedLoader.Result {
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
    
    func makeImage(id: UUID = UUID(), description: String? = nil, location: String? = nil, image: URL = anyURL()) -> (image: FeedImage, json: [String: Any]) {
        let feedImage = FeedImage(id: id, description: description, location: location, imageUrl: image)
        
        let json = dictFrom(feedImage: feedImage)
        
        return (feedImage, json)
    }
    
    private func dictFrom(feedImage: FeedImage) -> [String: Any] {
        
        return [
            "id"            : feedImage.id.uuidString,
            "image"         : feedImage.url.absoluteString,
            "location"      : feedImage.location,
            "description"   : feedImage.description
            ]
            .reduce(into: [String: Any]()) { result, dict in
                if let value = dict.value {
                    result[dict.key] = value
                }
        }
    }
    
}
