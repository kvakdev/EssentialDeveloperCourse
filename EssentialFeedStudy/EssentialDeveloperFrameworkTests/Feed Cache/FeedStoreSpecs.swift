//
//  FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retreiveHasNoSideEffectsOnEmptyCache()
    func test_retreivingTwice_hasNoSideEffects()
    func test_retreivingNonEmptyCache_returnsInsertedFeed()
    func test_delete_removesOldCache()
    func test_inserting_overridesPreviousCache()
}

protocol FailableInsertStore: FeedStoreSpecs {
    func test_insert_deliversErrorIfAny()
    func test_insertError_hasNoSideEffects()
}

protocol FailableDeleteStore: FeedStoreSpecs {
    func test_delete_returnsFailureOnDeleteError()
    func test_deleteError_hasNoSideEffects()
}

protocol FailableRetreiveStore: FeedStoreSpecs {
    func test_retreivingCorruptData_returnsFailure()
    func test_retreiveError_hasNoSideEffects()
}

protocol SerialFeedStore: FeedStoreSpecs {
    func test_sideEffect_runSerially()
}

typealias CombinedFeedStoreSpecs = FailableInsertStore & FailableDeleteStore & FailableRetreiveStore & SerialFeedStore
