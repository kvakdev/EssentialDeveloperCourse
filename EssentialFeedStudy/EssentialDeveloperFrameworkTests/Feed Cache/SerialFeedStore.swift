//
//  SerialFeedStore.swift
//  EssentialFeedTests
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import EssentialFeed
import XCTest

extension SerialFeedStore where Self: XCTestCase {
    
    func assertSideEffectsRunSerially(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        var operations = [XCTestExpectation]()
        
        let op1 = expectation(description: "Operation1")
        sut.insert([uniqueFeed().local], timestamp: Date()) { _ in
            operations.append(op1)
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation2")
        sut.deleteCachedFeed { _ in
            operations.append(op2)
            op2.fulfill()
        }
        
        let op3 = expectation(description: "Operation3")
        sut.retrieve { _ in
            operations.append(op3)
            op3.fulfill()
        }
        wait(for: [op1, op2, op3], timeout: 5)
        
        XCTAssertEqual([op1, op2, op3], operations, "order is not consistent", file: file, line: line)
    }
    
}
