//
//  FeedCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/24/22.
//

import XCTest
import EssentialFeed


class FeedCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    let cache: FeedCache
    
    init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> ()) {
        decoratee.load() { [weak self] result in
            completion(result.map { feed in
                self?.saveIgnoringResult(feed)
                
                return feed
            })
        }
    }
    
    private func saveIgnoringResult(_ feed: [FeedImage]) {
        cache.save(feed, completion: { _ in })
    }
}

class FeedCacheDecoratorTests: XCTestCase {

    func test_decorator_deliversLoaderResult() {
        let (sut, loader) = makeSUT()
        let feed = uniqueFeed()
        let expectedResult = FeedLoader.Result.success(feed)
        
        expect(sut: sut, toLoad: expectedResult) {
            loader.complete(expectedResult)
        }
    }
    
    func test_decorator_deliversLoaderFailure() {
        let (sut, loader) = makeSUT()
        let error = anyError()
        let expectedResult = FeedLoader.Result.failure(error)
        
        expect(sut: sut, toLoad: expectedResult) {
            loader.complete(expectedResult)
        }
    }
    
    func test_decorator_cachesFeedOnSuccess() {
        let feed = uniqueFeed()
        let (sut, cachingLoader) = makeSUT()
        
        sut.load(completion: { _ in })
        cachingLoader.complete(.success(feed))
        
        XCTAssertEqual(cachingLoader.messages, [.save(feed)])
    }
    
    func test_decorator_doesNotCacheFeedOnFailure() {
        let (sut, cachingLoader) = makeSUT()
        
        sut.load(completion: { _ in })
        cachingLoader.complete(.failure(anyError()))
        
        XCTAssertEqual(cachingLoader.messages, [])
    }
    
    func expect(sut: FeedLoader, toLoad expectedResult: FeedLoader.Result, when action: VoidClosure, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load to complete")
        
        sut.load { result in
            switch (result, expectedResult) {
            case (.success(let recievedFeed), .success(let expectedFeed)):
                XCTAssertEqual(recievedFeed, expectedFeed, file: file, line: line)
            case (.failure(let recievedError), .failure(let expectedError)):
                XCTAssertEqual((recievedError as NSError), (expectedError as NSError), file: file, line: line)
            default: XCTFail("expected \(expectedResult) got \(String(describing: result)) instead", file: file, line: line)
            }

            exp.fulfill()
        }
        
        action()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedLoader, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedCacheDecorator(decoratee: loader, cache: loader)
        
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader, FeedCache {
        enum Message: Equatable {
            case save([FeedImage])
        }
        
        var messages: [Message] = []
        
        func save(_ feedImages: [FeedImage], completion: @escaping (SaveResult) -> Void) {
            messages.append(.save(feedImages))
        }
        
        var completions: [(FeedLoader.Result) -> ()] = []
        
        func load(completion: @escaping (FeedLoader.Result) -> ()) {
            completions.append(completion)
        }
        
        func complete(_ result: FeedLoader.Result, at index: Int = 0) {
            self.completions[index](result)
        }
    }
}
