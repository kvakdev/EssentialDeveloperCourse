//
//  CodableFeedStore.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 5/7/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

class CodableFeedStore {
    func retrieve(completion: @escaping (FeedRetrieveResult) -> Swift.Void) {
        completion(.empty)
    }
}

class CodableFeedStoreTests: XCTestCase {
    
    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "waiting for retrieve to complete")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("expected empty got \(result) instead")
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = CodableFeedStore()
        let exp = expectation(description: "waiting for retrieve to complete")
        sut.retrieve { firstResult in
            sut.retrieve { secondResult in
                switch (firstResult, secondResult){
                case (.empty, .empty):
                    break
                default:
                    XCTFail("expected empty got \(firstResult) and \(secondResult) instead")
                }
                exp.fulfill()
            }
        }
        wait(for: [exp], timeout: 1.0)
    }
}
