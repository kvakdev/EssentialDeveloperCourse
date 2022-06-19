//
//  CacheFeedImageUseCase.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest

class LocalFeedImageLoader {
    let store: Any
    
    init(store: Any) {
        self.store = store
    }
    
}

class LoadFeedImageFromLocalStoreUseCaseTests: XCTestCase {

    func test_init_doesNotMessageOnCreation() {
        let store = ImageStoreSpy()
        _ = LocalFeedImageLoader(store: store)
        
        XCTAssertTrue(store.messages.isEmpty)
    }
    
    class ImageStoreSpy {
        var messages: [Any] = []
        
        
    }
}
