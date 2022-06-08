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
        expect(sut: sut, toRetreive: .success(.none), file: file, line: line)
    }
    
    
    func assertRetreivingTwiceHasNoSideEffects(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toRetreiveTwice: .success(.none), file: file, line: line)
    }
    
    func assertRetreiveReturnsInsertedFeed(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueFeed().local
        let inputTimestamp = Date()
        
        insert(sut: sut, feed: [feed], timestamp: inputTimestamp)
        expect(sut: sut, toRetreive: .success((feed: [feed], timestamp: inputTimestamp)), file: file, line: line)
    }
    
    func assertInsertingOverridesPreviousCache(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let firstFeed = uniqueFeed().local
        let firstTimestamp = Date().adding(seconds: -1)
        let secondFeed = uniqueFeed().local
        let secondTimestamp = Date()
        
        insert(sut: sut, feed: [firstFeed], timestamp: firstTimestamp)
        insert(sut: sut, feed: [secondFeed], timestamp: secondTimestamp)
        
        expect(sut: sut, toRetreive: .success((feed: [secondFeed], timestamp: secondTimestamp)), file: file, line: line)
    }
    
    func assertDeleteRemovesOldCache(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(sut: sut, feed: [uniqueFeed().local], timestamp: Date())
        deleteCache(sut: sut)
        expect(sut: sut, toRetreive: .success(.none), file: file, line: line)
    }
    
    @discardableResult
    func deleteCache(sut: FeedStore) -> FeedStore.TransactioResult? {
        let exp = expectation(description: "wait for delete to complete")
        var result: FeedStore.TransactioResult?
        
        sut.deleteCachedFeed { deletionResult in
            result = deletionResult
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        return result
    }
    
    @discardableResult
    func insert(sut: FeedStore, feed: [LocalFeedImage], timestamp: Date) -> FeedStore.TransactioResult? {
        let exp = expectation(description: "wait for retreive to complete")
        var insertionResult: FeedStore.TransactioResult?
        sut.insert(feed, timestamp: timestamp) { result in
            insertionResult = result
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
        return insertionResult
    }
    
    func expect(sut: FeedStore, toRetreive expectedResult: RetrieveResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for retreive to complete")
        
        sut.retrieve { result in
            switch (result, expectedResult) {
            case (.success(.none), .success(.none)), (.failure, .failure):
                exp.fulfill()
            case (.success(let resultFeedCache), .success(let expectedCache)):
                XCTAssertEqual(resultFeedCache?.feed, expectedCache?.feed, file: file, line: line)
                XCTAssertEqual(resultFeedCache?.timestamp, expectedCache?.timestamp, file: file, line: line)
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
