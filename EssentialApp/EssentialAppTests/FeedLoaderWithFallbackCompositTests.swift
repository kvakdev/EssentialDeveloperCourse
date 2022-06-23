//
//  FeedLoaderWithFallbackCompositTests.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/22/22.
//

import XCTest
import EssentialFeed
import EssentialApp

class FeedLoaderWithFallbackCompositTests: XCTestCase {
    
    func test_feedLoader_deliversPrimaryResultOnPrimarySuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        expect(sut: sut, toLoad: .success(primaryFeed))
    }
    
    func test_loadFeed_deliversFallbackResultOnPrimaryLoaderFailure() {
        let fallbackFeed = uniqueFeed()
        let sut = makeSUT(primaryResult: .failure(anyError()), fallbackResult: .success(fallbackFeed))
        
        expect(sut: sut, toLoad: .success(fallbackFeed))
    }
    
    func test_loadFeed_deliversFallbackFailureOnPrimaryAndFallbackFailure() {
        let fallbackError = anyError(code: 1)
        let primaryError = anyError(code: 0)
        let fallbackResult = FeedLoader.Result.failure(fallbackError)
        let sut = makeSUT(primaryResult: .failure(primaryError), fallbackResult: fallbackResult)
        
        expect(sut: sut, toLoad: fallbackResult)
    }
    
    private func expect(sut: FeedLoader, toLoad result: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load to complete")
        sut.load { receivedResult in
            switch (receivedResult, result) {
            case (.success(let feed), .success(let expectedFeed)):
                XCTAssertEqual(feed, expectedFeed, file: file, line: line)
            case (.failure(let error), .failure(let expectedError)):
                XCTAssertEqual((error as NSError), (expectedError as NSError))
            default: XCTFail("Expected \(result) got \(receivedResult) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func makeSUT(primaryResult: FeedLoader.Result, fallbackResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) -> FeedLoader {
        let remoteStub = FeedLoaderStub(primaryResult)
        let localStub = FeedLoaderStub(fallbackResult)
        let sut = FeedLoaderWithFallbackComposit(primary: remoteStub, fallback: localStub)
        
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private class FeedLoaderStub: FeedLoader {
        let result: FeedLoader.Result
        
        init(_ result: FeedLoader.Result) {
            self.result = result
        }
        
        func load(completion: @escaping (FeedLoader.Result) -> ()) {
            completion(result)
        }
    }
}
