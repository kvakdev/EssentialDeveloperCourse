//
//  FeedApiEndToEndTests.swift
//  FeedApiEndToEndTests
//
//  Created by Andre Kvashuk on 4/19/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class FeedApiEndToEndTests: XCTestCase {
    
    func test_endToEndTest_ReturnsTheFixedFeedData() {
        switch loadFeed() {
        case .failure(let error):
            XCTFail("expected success with 8 items got \(error) instead")
        case .success(let feedItems):
            XCTAssertEqual(feedImage(at: 0), feedItems[0])
            XCTAssertEqual(feedImage(at: 1), feedItems[1])
            XCTAssertEqual(feedImage(at: 2), feedItems[2])
            XCTAssertEqual(feedImage(at: 3), feedItems[3])
            XCTAssertEqual(feedImage(at: 4), feedItems[4])
            XCTAssertEqual(feedImage(at: 5), feedItems[5])
            XCTAssertEqual(feedImage(at: 6), feedItems[6])
            XCTAssertEqual(feedImage(at: 7), feedItems[7])
        }
    }
    
    func loadFeed(file: StaticString = #file, line: UInt = #line) -> FeedLoaderResult {
        let client = URLSessionHTTPClient(session: URLSession(configuration: .ephemeral))
        let feedURL = URL(string: "https://essentialdeveloper.com/feed-case-study/test-api/feed")!
        let sut = RemoteFeedLoader(url: feedURL, client: client)
        let exp = expectation(description: "waiting for load to complete")
        var receivedResult: FeedLoaderResult!
        
        sut.load { result in
            receivedResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    //MARK: - Helper methods
    private func id(at index: Int) -> UUID {
        return UUID(uuidString: [
            "73A7F70C-75DA-4C2E-B5A3-EED40DC53AA6",
            "BA298A85-6275-48D3-8315-9C8F7C1CD109",
            "5A0D45B3-8E26-4385-8C5D-213E160A5E3C",
            "FF0ECFE2-2879-403F-8DBE-A83B4010B340",
            "DC97EF5E-2CC9-4905-A8AD-3C351C311001",
            "557D87F1-25D3-4D77-82E9-364B2ED9CB30",
            "A83284EF-C2DF-415D-AB73-2A9B8B04950B",
            "F79BD7F8-063F-46E2-8147-A67635C3BB01"
            ][index])!
    }
    
    private func description(at index: Int) -> String? {
        return [
            "Description 1",
            nil,
            "Description 3",
            nil,
            "Description 5",
            "Description 6",
            "Description 7",
            "Description 8"
            ][index]
    }
    
    private func location(at index: Int) -> String? {
        return [
            "Location 1",
            "Location 2",
            nil,
            nil,
            "Location 5",
            "Location 6",
            "Location 7",
            "Location 8"
            ][index]
    }
    
    private func imageURL(at index: Int) -> URL {
        return URL(string: "https://url-\(index+1).com")!
    }
    
    private func feedImage(at index: Int) -> FeedImage {
        return FeedImage(id: id(at: index),
                        description: description(at: index),
                        location: location(at: index),
                        imageUrl: imageURL(at: index)
        )
    }
}
