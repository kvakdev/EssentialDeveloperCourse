//
//  CodableFeedStore.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/6/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class CodableFeedStoreTests: XCTestCase, CombinedFeedStoreSpecs {
  
    override func setUp() {
        super.setUp()
        
        try? removeSideEffects()
    }
    
    override func tearDown() {
        super.tearDown()
        
        try? removeSideEffects()
    }
    
    func test_retreiveHasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        
        assertStoreInitHasNoSideEffects(sut)
    }
    
    func test_retreivingTwice_hasNoSideEffects() {
        let sut = makeSUT()
        
        assertRetreivingTwiceHasNoSideEffects(sut)
    }

    func test_retreivingNonEmptyCache_returnsInsertedFeed() {
        let sut = makeSUT()
        
        assertRetreiveReturnsInsertedFeed(sut)
    }
    
    func test_inserting_overridesPreviousCache() {
        let sut = makeSUT()
        
        assertInsertingOverridesPreviousCache(sut)
    }
    
    func test_insertError_hasNoSideEffects() {
        let invalidURL = anyURL()
        let sut = makeSUT(storeURL: invalidURL)
        
        assertInsertErrorHasNoSideEffects(sut)
    }

    func test_deleteError_hasNoSideEffects() {
        let unauthorizedURL = systemCacheDirectory()
        let sut = makeSUT(storeURL: unauthorizedURL)
        
        assertDeleteErrorHasNoSideEffects(sut)
    }
    
    func test_delete_removesOldCache() {
        let sut = makeSUT()
        
        assertDeleteRemovesOldCache(sut)
    }
    
    func test_delete_returnsFailureOnDeleteError() {
        let unautorizedURL = systemCacheDirectory()
        let sut = makeSUT(storeURL: unautorizedURL)
        
        assertDeletereturnsFailureOnDeleteError(sut)
    }
    
    private func systemCacheDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .systemDomainMask).first!
    }
    
    func test_retreivingCorruptData_returnsFailure() {
        let corruptData = Data("anyString".utf8)
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! corruptData.write(to: storeURL)
        
        assertThatRetreiveDeliverFailureOnRetreiveError(sut)
    }
    
    func test_retreiveError_hasNoSideEffects() {
        let corruptData = Data("anyString".utf8)
        let storeURL = testSpecificStoreURL()
        let sut = makeSUT(storeURL: storeURL)
        
        try! corruptData.write(to: storeURL)
        
        assertThatRetreiveErrorHasNoSideEffects(sut)
    }
    
    func test_insert_deliversErrorIfAny() {
        let invalidURL = anyURL()
        let sut = makeSUT(storeURL: invalidURL)
        
        assertInsertErrorReturnsFailure(sut)
    }
    
    func test_sideEffect_runSerially() {
        let sut = makeSUT()
        
        assertSideEffectsRunSerially(sut)
    }
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStore {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL())
        
        trackMemoryLeaks(sut, file: file, line: line)
        
        return sut
    }
    
    private func testSpecificStoreURL() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!.appendingPathComponent("\(type(of: Self.self)).store")
    }
    
    private func removeSideEffects() throws {
        try FileManager.default.removeItem(at: testSpecificStoreURL())
    }
}
