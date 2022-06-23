//
//  MemoryLeakTracking.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/23/22.
//

import XCTest

extension XCTestCase {
    func trackMemoryLeaks(_ sut: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak sut] in
            XCTAssertNil(sut, "expected to be nil potential memory leak", file: file, line: line)
        }
    }
}
