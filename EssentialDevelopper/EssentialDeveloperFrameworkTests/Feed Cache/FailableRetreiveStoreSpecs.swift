//
//  FailableRetreiveStoreSpecs.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import EssentialDeveloperFramework
import XCTest

extension FailableRetreiveStore where Self: XCTestCase {
    
    func assertThatRetreiveDeliverFailureOnRetreiveError(_ sut: FeedStore) {
        expect(sut: sut, toRetreive: .failure(anyNSError()))
    }
    
    func assertThatRetreiveErrorHasNoSideEffects(_ sut: FeedStore) {
        expect(sut: sut, toRetreiveTwice: .failure(anyNSError()))
    }
    
}
