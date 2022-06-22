//
//  FeedCacheIntegrationTests.swift
//  FeedCacheIntegrationTests
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        removeSideEffects()
    }
    
    override func tearDown() {
        super.tearDown()
        
        removeSideEffects()
    }
    
    private func removeSideEffects() {
        try? FileManager.default.removeItem(at: testSpecificaStoreURL())
    }
    
    func test_cache_hasNoSideEffectsReadingFromAnEmptyCache() {
        let sut = makeFeedLoader()
        
        expect(sut, toLoad: .success([]))
    }
    
    func test_cache_storesTheDataOnDisk() {
        let writeSUT = makeFeedLoader()
        let readSUT = makeFeedLoader()
        let feed = [uniqueFeed().model]
  
        expect(writeSUT, toSave: feed)
        expect(readSUT, toLoad: .success(feed))
    }
    
    func test_save_overridesOldCacheOnDisk() {
        let writeSUTOne = makeFeedLoader()
        let writeSUTTwo = makeFeedLoader()
        let readSUT = makeFeedLoader()
        let feedOne = [uniqueFeed().model]
        let feedTwo = [uniqueFeed().model]
  
        expect(writeSUTOne, toSave: feedOne)
        expect(writeSUTTwo, toSave: feedTwo)
        expect(readSUT, toLoad: .success(feedTwo))
    }
    
    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let imageLoaderToPerformSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let image = uniqueFeedImage()
        let dataToSave = anyData()
        
        expect(feedLoader, toSave: [image])
        save(dataToSave, for: image.url, with: imageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
    }
    
    func test_validateFeedCache_doesNotDeleteRecentlySavedFeed() {
        let feedLoaderToPerformSave = makeFeedLoader(date: Date.distantPast)
        let feedLoaderToPerformValidation = makeFeedLoader()
        let feed = uniqueFeed()
        
        expect(feedLoaderToPerformSave, toSave: [feed.model])
        validateCacheWith(feedLoaderToPerformValidation)
        
        expect(feedLoaderToPerformSave, toLoad: .success([]))
    }
    
    func test_validateFeedCache_deletesCacheFromDistantPast() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformValidation = makeFeedLoader()
        let feed = uniqueFeed()
        
        expect(feedLoaderToPerformSave, toSave: [feed.model])
        validateCacheWith(feedLoaderToPerformValidation)
        
        expect(feedLoaderToPerformSave, toLoad: .success([feed.model]))
    }
    
    private func validateCacheWith(_ feedLoader: LocalFeedLoader) {
        let exp = expectation(description: "wait for validate to complete")
        
        feedLoader.validateCache(completion: { _ in
            exp.fulfill()
        })
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ loader: LocalFeedImageLoader, toLoad data: Data, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load to complete")
        
        _ = loader.loadImage(with: url) { result in
            switch result {
            case .success(let resultData):
                XCTAssertEqual(resultData, data, file: file, line: line)
            case .failure:
                XCTFail("Expected result got error instead")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
    }

    private func save(_ imageData: Data, for url: URL, with loader: LocalFeedImageLoader) {
        let exp = expectation(description: "wait for save to complete")
        loader.save(image: imageData, for: url) { _ in exp.fulfill() }
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedLoader, toSave feed: [FeedImage]) {
        let exp = expectation(description: "wait for save to complete")
        
        sut.save(feed) { result in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for load to complete")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let retreivedFeed), .success(let expectedFeed)):
                XCTAssertEqual(retreivedFeed, expectedFeed, file: file, line: line)
            case (.failure, .failure):
                break
            default:
                XCTFail("expected \(expectedResult), got \(receivedResult) instead")
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func makeImageLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedImageLoader {
        let storeURL = testSpecificaStoreURL()
        let feedStore = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedImageLoader(store: feedStore)
         
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(feedStore, file: file, line: line)
        
        return sut
    }
    
    func makeFeedLoader(date: Date = Date(), file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificaStoreURL()
        let feedStore = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(feedStore, timestamp: { date })
         
        trackMemoryLeaks(feedStore, file: file, line: line)
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    func testSpecificaStoreURL() -> URL {
        return cachesDirectory().appendingPathComponent("\(type(of: self)).store")
    }
    
    func cachesDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
