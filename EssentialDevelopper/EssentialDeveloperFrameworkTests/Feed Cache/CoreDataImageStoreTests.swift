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

class CoreDataRetreiveTask: CancellableTask {
    func cancel() {
        
    }
}

extension CoreDataFeedStore: ImageStore {
    
    public func insert(image data: Data, for url: URL, completion: @escaping Closure<InsertResult>) {
        completion(.success(()))
    }
    
    @discardableResult
    public func retrieveImageData(from url: URL, completion: @escaping (ImageStore.RetrieveResult) -> Void) -> CancellableTask {
        
        completion(.success(.none))
        
        return CoreDataRetreiveTask()
    }
}

class CoreDataImageStoreTests: XCTestCase {
    
    func test_retrieve_hasNoSideEffectsAndReturnsEmptyOnEmptyStore() {
        let sut = makeSUT()
        
        expect(sut, toCompleteRetrievalWith: .success(.none), for: anyURL())
    }
    
    func test_retrieve_returnsInsertedDataForTheSameUrl() {
        let sut = makeSUT()
        let imageData = Data(repeating: 1, count: 10)
        let url = URL(string: "http://some-image-url.com")!
        let exp = expectation(description: "wait for insert to complete")
        
        sut.insert(image: imageData, for: url) { result in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
        expect(sut, toCompleteRetrievalWith: .success(.none), for: anyURL())
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
}
