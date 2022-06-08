//
//  FailableDeleteStoreSpecs.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework

extension FailableDeleteStore where Self: XCTestCase {
    
    func assertDeletereturnsFailureOnDeleteError(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        let error = deleteCache(sut: sut)
        
        XCTAssertNotNil(error, "expected to get permission error", file: file, line: line)
    }
    
    func assertDeleteErrorHasNoSideEffects(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        deleteCache(sut: sut)
        expect(sut: sut, toRetreive: .success(.none), file: file, line: line)
    }
    
}
