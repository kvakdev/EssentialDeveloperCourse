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
        XCTAssertNoThrow(try launch())
    }
    
    func launch() throws -> FeedViewController {
        let sut = SceneDelegate()
        sut.window = UIWindow()
        sut.setup()
        
        guard
            let navController = sut.window?.rootViewController as? UINavigationController,
            let vc = navController.viewControllers[0] as? FeedViewController else {
            
            throw NSError(domain: "No Navigation Controller", code: 0)
        }
        
        return vc
    }
    
    func test_app_rendersCells() {
 
    }
    
    func test_appInOfflineMode_rendersCachesFeed() {
      
    }
    
    func test_appInOfflineModeWithNoCache_rendersEmptyFeed() {
    
    }
}
