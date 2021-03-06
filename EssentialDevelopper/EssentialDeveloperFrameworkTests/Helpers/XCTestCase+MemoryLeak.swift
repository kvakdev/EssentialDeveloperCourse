//
//  XCTestCase+MemoryLeak.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 4/19/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest



extension XCTestCase {
    func trackMemoryLeaks(_ sut: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, "expected to be nil", file: file, line: line)
        }
    }
}
