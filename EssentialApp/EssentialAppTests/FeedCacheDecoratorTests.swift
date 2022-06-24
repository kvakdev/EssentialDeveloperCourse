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
    
    init(decoratee: FeedLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> ()) {
        decoratee.load(completion: completion)
    }
}

class FeedCacheDecoratorTests: XCTestCase {

    func test_decorator_deliversLoaderResult() {
        let loader = LoaderSpy()
        let sut = FeedCacheDecorator(decoratee: loader)
        let feed = uniqueFeed()
        let expectedResult = FeedLoader.Result.success(feed)
        
        expect(sut: sut, toLoad: expectedResult) {
            loader.complete(expectedResult)
        }
    }
    
    func test_decorator_deliversLoaderFailure() {
        let loader = LoaderSpy()
        let sut = FeedCacheDecorator(decoratee: loader)
        let error = anyError()
        let expectedResult = FeedLoader.Result.failure(error)
        
        expect(sut: sut, toLoad: expectedResult) {
            loader.complete(expectedResult)
        }
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
    
    class LoaderSpy: FeedLoader {
        var completions: [(FeedLoader.Result) -> ()] = []
        
        func load(completion: @escaping (FeedLoader.Result) -> ()) {
            completions.append(completion)
        }
        
        func complete(_ result: FeedLoader.Result, at index: Int = 0) {
            self.completions[index](result)
        }
    }
}
