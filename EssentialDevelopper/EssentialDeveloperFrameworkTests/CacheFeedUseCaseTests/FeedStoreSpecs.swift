//
//  FeedStoreSpecs.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/7/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

protocol FeedStoreSpecs {
    func test_retrieve_hasNoSideEffectsOnEmptyCache()
    func test_retrieve_deliversTheInsertedValues()
    func test_retrieve_deliversTheSameValues()
    
    func test_insert_overwritesLatestResults()
    
    func test_delete_removesCacheOnNonEmptyCache()
    func test_delete_hasNoSideEffects()
    
    func test_operations_completeSerially()
}

protocol FailableInsertFeedStoreSpecs: FeedStoreSpecs {
    func test_insert_deliversSameInsertionErrorOnFailure()
}

protocol FailableRetrievFeedStoreSpecs: FeedStoreSpecs {
    func test_retrieve_deliversErrorOnCurruptedData()
}

protocol FailableDeleteFeedStore: FeedStoreSpecs {
    func test_delete_deliversErrorOnDeletionFailure()
}

typealias FailableFeedStore = FailableDeleteFeedStore & FailableInsertFeedStoreSpecs & FailableRetrievFeedStoreSpecs
