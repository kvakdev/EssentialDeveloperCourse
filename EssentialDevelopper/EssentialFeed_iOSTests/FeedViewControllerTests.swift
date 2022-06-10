//
//  FeedViewControllerTests.swift
//  EssentialFeed_iOSTests
//
//  Created by Andre Kvashuk on 6/10/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import UIKit

class FeedViewController: UIViewController {
    private var loader: LoaderSpy?
    
    convenience init(loader: LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loader?.load()
    }
}

class LoaderSpy {
    var loadCount: Int = 0
    
    func load() {
        loadCount += 1
    }
}

class FeedViewControllerTests: XCTestCase {
    func test_load_isNotIvokedOnInit() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    func test_load_isInvokedOnViewDidLoad() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCount, 1)
    }
}
