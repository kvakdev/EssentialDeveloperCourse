//
//  CoreDateFeedStore.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class CoreDataFeedStore: FeedStore {
    func deleteCachedFeed(completion: @escaping TransactionCompletion) {
        
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping TransactionCompletion) {
        
    }
    
    func retrieve(_ completion: @escaping RetrieveCompletion) {
        completion(.empty)
    }
}

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs {
    func test_insert_deliversErrorIfAny() {
        
    }
    
    func test_insertError_hasNoSideEffects() {
        
    }
    
    func test_delete_returnsFailureOnDeleteError() {
        
    }
    
    func test_deleteError_hasNoSideEffects() {
        
    }
    
    func test_retreivingCorruptData_returnsFailure() {
        
    }
    
    func test_retreiveError_hasNoSideEffects() {
        
    }
    
    func test_sideEffect_runSerially() {
        
    }
    
    func test_retreiveHasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        assertStoreInitHasNoSideEffects(sut)
    }
    
    func test_retreivingTwice_hasNoSideEffects() {
        
    }
    
    func test_retreivingNonEmptyCache_returnsInsertedFeed() {
        
    }
    
    func test_delete_removesOldCache() {
        
    }
    
    func test_inserting_overridesPreviousCache() {
        
    }
    
    func makeSUT() -> CoreDataFeedStore {
        let sut = CoreDataFeedStore()
        
        trackMemoryLeaks(sut)
        
        return sut
    }
}
