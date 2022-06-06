//
//  CodableFeedStore.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/6/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class CodableFeedStore {
    func retrieve(_ completion: @escaping FeedStore.RetrieveCompletion) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    func test_init() {
        let sut = CodableFeedStore()
        let expectedResult: RetrieveResult = .empty
        let exp = expectation(description: "wait for retreive to complete")
        sut.retrieve { result in
            switch (expectedResult, result) {
            case (.empty, .empty):
                exp.fulfill()
                break
            default:
                XCTFail("expected empty result, got \(result) instead")
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    func test_retreivingTwice_hasNoSideEffects() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "wait for retreive to complete")
        
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult) {
                case (.empty, .empty):
                    exp.fulfill()
                    break
                default:
                    XCTFail("expected empty results twice, got \(firstResult) and \(secondResult) instead")
                }
            }
        }
        
        wait(for: [exp], timeout: 1)
    }
    
}
