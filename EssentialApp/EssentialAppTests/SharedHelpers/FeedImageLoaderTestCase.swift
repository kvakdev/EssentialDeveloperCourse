//
//  FeedImageLoaderTestCase.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/25/22.
//

import XCTest
import EssentialFeed

protocol FeedImageLoaderTestCase: XCTestCase {}

extension FeedImageLoaderTestCase {
    
    func expect(sut: FeedImageLoader, toLoadResult expectedResult: FeedImageLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load to complete")
        let url = anyURL()
        
        _ = sut.loadImage(with: url) { result in
            switch (result, expectedResult) {
            case (.success(let data), .success(let expectedData)):
                XCTAssertEqual(data, expectedData)
                
            case (.failure(let error), .failure(let expectedError)):
                XCTAssertEqual((error as NSError), (expectedError as NSError))
            default:
                XCTFail("Expected \(expectedResult) got \(result) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
}
