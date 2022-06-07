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
    
    func assertStoreInitHasNoSideEffects(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toRetreive: .empty, file: file, line: line)
    }
    
    
    func assertRetreivingTwiceHasNoSideEffects(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toRetreiveTwice: .empty, file: file, line: line)
    }
    
    func assertRetreiveReturnsInsertedFeed(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueFeed().local
        let inputTimestamp = Date()
        
        insert(sut: sut, feed: [feed], timestamp: inputTimestamp)
        expect(sut: sut, toRetreive: .success(feed: [feed], timestamp: inputTimestamp), file: file, line: line)
    }
    
    func assertInsertingOverridesPreviousCache(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let firstFeed = uniqueFeed().local
        let firstTimestamp = Date().adding(seconds: -1)
        let secondFeed = uniqueFeed().local
        let secondTimestamp = Date()
        
        insert(sut: sut, feed: [firstFeed], timestamp: firstTimestamp)
        insert(sut: sut, feed: [secondFeed], timestamp: secondTimestamp)
        
        expect(sut: sut, toRetreive: .success(feed: [secondFeed], timestamp: secondTimestamp), file: file, line: line)
    }
    
    func assertDeleteRemovesOldCache(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(sut: sut, feed: [uniqueFeed().local], timestamp: Date())
        deleteCache(sut: sut)
        expect(sut: sut, toRetreive: .empty, file: file, line: line)
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
    
    @discardableResult
    func insert(sut: FeedStore, feed: [LocalFeedImage], timestamp: Date) -> Error? {
        let exp = expectation(description: "wait for retreive to complete")
        var receivedError: Error?
        sut.insert(feed, timestamp: timestamp) { error in
            receivedError = error
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        return receivedError
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
    
    func expect(sut: FeedStore, toRetreiveTwice result: RetrieveResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toRetreive: result, file: file, line: line)
        expect(sut: sut, toRetreive: result, file: file, line: line)
    }
    
}