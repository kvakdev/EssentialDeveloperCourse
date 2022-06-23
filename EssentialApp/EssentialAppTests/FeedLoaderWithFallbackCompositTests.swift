//
//  FeedLoaderWithFallbackCompositTests.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/22/22.
//

import XCTest
import EssentialFeed

class FeedLoaderComposit: FeedLoader {
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> ()) {
        primary.load() { [weak self] primaryResult in
            switch primaryResult {
            case .success(let success):
                completion(.success(success))
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}

class FeedLoaderStub: FeedLoader {
    let result: FeedLoader.Result
    
    init(_ result: FeedLoader.Result) {
        self.result = result
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> ()) {
        completion(result)
    }
}

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
        let sut = FeedLoaderComposit(primary: remoteStub, fallback: localStub)
        
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(),
                   description: nil,
                   location: nil,
                   imageUrl: anyURL())]
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
    
    private func anyError() -> NSError {
        NSError(domain: "CompositLoaderTests", code: 0)
    }
    
}

extension XCTestCase {
    func trackMemoryLeaks(_ sut: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, "expected to be nil potential memory leak", file: file, line: line)
        }
    }
}
