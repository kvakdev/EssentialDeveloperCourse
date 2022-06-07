//
//  FailableInsertStoreSpecs.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

extension FailableInsertStore where Self: XCTestCase {
    func assertInsertErrorReturnsFailure(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let error = insert(sut: sut, feed: [uniqueFeed().local], timestamp: Date())
        
        XCTAssertNotNil(error, "expectected insertion error", file: file, line: line)
    }
    
    func assertInsertErrorHasNoSideEffects(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        insert(sut: sut, feed: [uniqueFeed().local], timestamp: Date())
        
        expect(sut: sut, toRetreive: .empty)
    }
}
