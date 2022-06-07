//
//  FeedStoreSpecs+Helpers.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import XCTest
import EssentialDeveloperFramework

extension FeedStoreSpecs where Self: XCTestCase {
    
    func assertInsertingOverridesPreviousCache(_ sut: FeedStore) {
        let firstFeed = uniqueFeed().local
        let firstTimestamp = Date().adding(seconds: -1)
        let secondFeed = uniqueFeed().local
        let secondTimestamp = Date()
        
        insert(sut: sut, feed: [firstFeed], timestamp: firstTimestamp)
        expect(sut: sut, toRetreive: .success(feed: [firstFeed], timestamp: firstTimestamp))
        
        insert(sut: sut, feed: [secondFeed], timestamp: secondTimestamp)
        expect(sut: sut, toRetreive: .success(feed: [secondFeed], timestamp: secondTimestamp))
    }
    
    func assertInsertErrorHasNoSideEffects(_ sut: FeedStore) {
        let exp = expectation(description: "wait for insert to complete")
        
        sut.insert([uniqueFeed().local], timestamp: Date()) { error in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        expect(sut: sut, toRetreive: .empty)
    }
    
    func assertDeleteHasNoSideEffects(_ sut: FeedStore) {
        deleteCache(sut: sut)
        expect(sut: sut, toRetreive: .empty)
    }
    
    func assertDeleteRemovesOldCache(_ sut: FeedStore) {
        insert(sut: sut, feed: [uniqueFeed().local], timestamp: Date())
        deleteCache(sut: sut)
        expect(sut: sut, toRetreive: .empty)
    }
    
    func assertDeletereturnsFailureOnDeleteError(_ sut: FeedStore) {
        let error = deleteCache(sut: sut)
        
        XCTAssertNotNil(error, "expected to get permission error")
    }
    
    @discardableResult
    func deleteCache(sut: FeedStore) -> Error? {
        let exp = expectation(description: "wait for delete to complete")
        var receivedError: Error?
        
        sut.deleteCachedFeed { error in
            receivedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return receivedError
    }
    
    func insert(sut: FeedStore, feed: [LocalFeedImage], timestamp: Date) {
        let exp = expectation(description: "wait for retreive to complete")
        
        sut.insert(feed, timestamp: timestamp) { error in
            XCTAssertNil(error)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func expect(sut: FeedStore, toRetreive expectedResult: RetrieveResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for retreive to complete")
        
        sut.retrieve { result in
            switch (result, expectedResult) {
            case (.empty, .empty), (.failure, .failure):
                exp.fulfill()
            case (.success(let retreivedfeed, let timestamp), .success(feed: let expectedFeed, let expectedTimestamp)):
                XCTAssertEqual(retreivedfeed, expectedFeed, file: file, line: line)
                XCTAssertEqual(timestamp, expectedTimestamp, file: file, line: line)
                exp.fulfill()
            default:
                XCTFail("expected \(expectedResult) result, got \(result) instead", file: file, line: line)
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func expect(sut: FeedStore, toRetreiveTwice result: RetrieveResult) {
        expect(sut: sut, toRetreive: result)
        expect(sut: sut, toRetreive: result)
    }
    
}
