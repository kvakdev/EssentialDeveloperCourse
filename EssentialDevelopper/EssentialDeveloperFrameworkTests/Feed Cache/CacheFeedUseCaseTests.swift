//
//  CacheFeedUseCaseTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/5/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest

class FeedStore {
    var deletionCallCount = 0
}

class LocalFeedLoader {
    init(_ store: FeedStore) {
        
    }
}

class CacheFeedUseCaseTests: XCTestCase {
    func test_deletionIsNotInvoked_uponCreation() {
        let store = FeedStore()
        _ = LocalFeedLoader(store)
        
        XCTAssertEqual(store.deletionCallCount, 0)
    }
}
