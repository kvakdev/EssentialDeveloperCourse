//
//  CoreDataImageStoreTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed
import CoreData


class CoreDataImageStoreTests: XCTestCase {
    
    func test_retrieve_hasNoSideEffectsAndReturnsEmptyOnEmptyStore() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: .success(.none), for: anyURL())
    }
    
    func test_retrieve_returnsInsertedDataForTheSameUrl() {
        let sut = makeSUT()
        let imageData = Data(repeating: 1, count: 10)
        let url = URL(string: "http://some-image-url.com")!
        let nonMatchingUrl = URL(string: "http://different-image-url.com")!
        
        insert(in: sut, at: url, feed: [localImage(url)], imageData: imageData)
        expect(sut, toCompleteRetrievalWith: .success(.none), for: nonMatchingUrl)
    }
    
    func test_retrieveReturnsPreveiouslyInsertedData() {
        let sut = makeSUT()
        let data = anyData()
        let matchingUrl = someURL()
        
        insert(in: sut, at: someURL(), feed: [localImage(matchingUrl)], imageData: data)
        expect(sut, toCompleteRetrievalWith: .success(data), for: matchingUrl)
    }
    
    func test_retrieve_returnsLastInsertedDataForTheSameUrl() {
        let sut = makeSUT()
        let firstData = Data("first".utf8)
        let lastData = Data("last".utf8)
        let url = URL(string: "http://some-image-url.com")!
        
        insert(in: sut, at: url, feed: [localImage(url)], imageData: firstData)
        insert(in: sut, at: url, feed: [localImage(url)], imageData: lastData)
        expect(sut, toCompleteRetrievalWith: .success(lastData), for: url)
    }
    
    func test_sideEffects_runSerially() {
        let url = someURL()
        let sut = makeSUT()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert([localImage(url)], timestamp: Date()) { _ in op1.fulfill() }
        
        let op2 = expectation(description: "Operation 2")
        sut.insert(image: anyData(), for: url) { _ in op2.fulfill() }
        
        let op3 = expectation(description: "Operation 3")
        sut.insert(image: anyData(), for: url) { _ in op3.fulfill() }
        
        wait(for: [op1, op2, op3], timeout: 1, enforceOrder: true)
    }
    
    func makeSUT() -> CoreDataFeedStore {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(bundle: bundle, storeURL: storeURL)
        
        trackMemoryLeaks(sut)
        
        return sut
    }
    
    func insert(in sut: CoreDataFeedStore, at url: URL, feed: [LocalFeedImage], imageData: Data, file: StaticString = #file, line: UInt = #line) {
        
        let exp = expectation(description: "wait for insert to complete")
        
        sut.insert(feed, timestamp: Date()) { result in
            switch result {
            case .success:
                sut.insert(image: imageData, for: url) { imageInsertResult in
                    switch imageInsertResult {
                    case .success:
                        exp.fulfill()
                    case .failure:
                        XCTFail("Expected successful image insert for url\(url), image data \(imageData)", file: file, line: line)
                    }
                }
            case .failure:
                XCTFail("Expected successful insert for feed \(feed)", file: file, line: line)
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteRetrievalWith expectedResult: ImageStore.RetrieveResult, for url: URL,  file: StaticString = #file, line: UInt = #line) {
             let exp = expectation(description: "Wait for load completion")
             sut.retrieveImageData(from: url) { receivedResult in
                 switch (receivedResult, expectedResult) {
                 case let (.success( receivedData), .success(expectedData)):
                     XCTAssertEqual(receivedData, expectedData, file: file, line: line)

                 default:
                     XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
                 }
                 exp.fulfill()
             }
             wait(for: [exp], timeout: 1.0)
         }
    
    private func someURL() -> URL {
        URL(string: "http://some-image-url.com")!
    }
    
    private func localImage(_ url: URL) -> LocalFeedImage {
        return LocalFeedImage(id: UUID(), url: url)
    }
}
