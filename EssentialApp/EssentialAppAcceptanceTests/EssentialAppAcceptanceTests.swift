//
//  EssentialAppAcceptanceTests.swift
//  EssentialAppAcceptanceTests
//
//  Created by Andre Kvashuk on 6/25/22.
//

import XCTest

class EssentialAppAcceptanceTests: XCTestCase {
    func test_app_rendersCells() {
        let app = XCUIApplication()
        app.launchArguments = ["-reset", "-connectivity", "online"]
        app.launch()
        
        let cells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cells.count, 2)
        
        let imageViews = app.images.matching(identifier: "feed-image-view")
        XCTAssertTrue(imageViews.element.exists)
    }
    
    func test_appInOfflineMode_rendersCachesFeed() {
        let onlineApp = XCUIApplication()
        onlineApp.launchArguments = ["-reset", "-connectivity", "online"]
        onlineApp.launch()
        onlineApp.terminate()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        let cells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cells.count, 2)
        
        let imageViews = offlineApp.images.matching(identifier: "feed-image-view")
        XCTAssertTrue(imageViews.element.exists)
    }
    
    func test_appInOfflineModeWithNoCache_rendersEmptyFeed() {
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-reset", "-connectivity", "offline"]
        offlineApp.launch()
        
        let cells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cells.count, 0)
        
        let imageViews = offlineApp.images.matching(identifier: "feed-image-view")
        XCTAssertFalse(imageViews.element.exists)
    }
}
