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
        
        let exp = expectation(description: "wait for load to complete")
        let sut = makeSUT(primaryResult: .success(primaryFeed), fallbackResult: .success(fallbackFeed))
        
        sut.load { result in
            switch result {
            case .success(let feed):
                XCTAssertEqual(feed, primaryFeed)
            case .failure(let failure):
                XCTFail("Expected result got \(failure) instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }
    
    func test_loadFeed_deliversFallbackResultOnPrimaryLoaderFailure() {
        let primaryResult = FeedLoader.Result.failure(anyError())
        let fallbackFeed = uniqueFeed()
        let fallbackResult = FeedLoader.Result.success(fallbackFeed)
        let primaryLoader = FeedLoaderStub(primaryResult)
        let fallbackLoader = FeedLoaderStub(fallbackResult)
        let exp = expectation(description: "wait for load to complete")
        let sut = FeedLoaderComposit(primary: primaryLoader, fallback: fallbackLoader)
        
        sut.load { result in
            switch result {
            case .success(let feed):
                XCTAssertEqual(feed, fallbackFeed)
            case .failure(let error):
                XCTFail("Expected \(fallbackResult) got \(error) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
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
