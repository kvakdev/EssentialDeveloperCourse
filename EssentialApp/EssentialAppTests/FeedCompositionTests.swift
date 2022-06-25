//
//  FeedCompositionTests.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/25/22.
//

import XCTest
import EssentialFeed_iOS
@testable import EssentialApp

class FeedCompositionTests: XCTestCase {
    func test_app_displaysFeedViewController() {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.setup()
        
        guard let navController = sut.window?.rootViewController as? UINavigationController else {
            XCTFail("Expected UINavigationController subclass")
            return
        }
        
        XCTAssertTrue(navController.viewControllers[0] is FeedViewController)
    }
}
