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
    
    init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> ()) {
        primary.load(completion: completion)
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
    func test_feedLoaderDeliversPrimaryResultOnPrimarySuccess() {
        let primaryFeed = uniqueFeed()
        let fallbackFeed = uniqueFeed()
        let remoteStub = FeedLoaderStub(.success(primaryFeed))
        let localStub = FeedLoaderStub(.success(fallbackFeed))
        let sut = FeedLoaderComposit(primary: remoteStub, fallback: localStub)
        let exp = expectation(description: "wait for load to complete")
        
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
    
    private func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(),
                   description: nil,
                   location: nil,
                   imageUrl: anyURL())]
    }
    
    private func anyURL() -> URL {
        URL(string: "http://any-url.com")!
    }
}
