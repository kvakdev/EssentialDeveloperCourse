//
//  CoreDateFeedStore.swift
//  EssentialFeedTests
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed

class CoreDataFeedStoreTests: XCTestCase, FeedStoreSpecs, SerialFeedStore {
  
    func test_sideEffect_runSerially() {
        assertSideEffectsRunSerially(makeSUT())
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
    
    func test_delete_removesOldCache() {
        assertDeleteRemovesOldCache(makeSUT())
    }
    
    func test_inserting_overridesPreviousCache() {
        assertInsertingOverridesPreviousCache(makeSUT())
    }
    
    func makeSUT() -> CoreDataFeedStore {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(bundle: bundle, storeURL: storeURL)
        
        trackMemoryLeaks(sut)
        
        return sut
    }
}
