//
//  FeedViewControllerTests.swift
//  EssentialFeed_iOSTests
//
//  Created by Andre Kvashuk on 6/10/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed

class FeedViewController {
    init(_ loader: LoaderSpy) {
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LoaderSpy {
    var loadCount: Int = 0
}

class FeedViewControllerTests: XCTestCase {
    func test_load_isNotIvokedOnInit() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader)
        
        XCTAssertEqual(loader.loadCount, 0)
    }
}
