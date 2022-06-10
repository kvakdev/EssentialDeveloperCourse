//
//  FailableRetreiveStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import EssentialFeed
import XCTest

extension FailableRetreiveStore where Self: XCTestCase {
    
    func assertThatRetreiveDeliverFailureOnRetreiveError(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toRetreive: .failure(anyNSError()), file: file, line: line)
    }
    
    func assertThatRetreiveErrorHasNoSideEffects(_ sut: FeedStore, file: StaticString = #file, line: UInt = #line) {
        expect(sut: sut, toRetreiveTwice: .failure(anyNSError()), file: file, line: line)
    }
    
}
