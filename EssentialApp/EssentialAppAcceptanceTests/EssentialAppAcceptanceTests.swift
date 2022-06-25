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
        app.launch()
        
        let cells = app.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cells.count, 22)
        
        let imageViews = app.images.matching(identifier: "feed-image-view")
        XCTAssertTrue(imageViews.element.exists)
    }
    
    func test_appInOfflineMode_rendersCachesFeed() {
        let onlineApp = XCUIApplication()
        onlineApp.launch()
        onlineApp.terminate()
        
        let offlineApp = XCUIApplication()
        offlineApp.launchArguments = ["-connectivity", "offline"]
        offlineApp.launch()
        
        let cells = offlineApp.cells.matching(identifier: "feed-image-cell")
        XCTAssertEqual(cells.count, 22)
        
        let imageViews = offlineApp.images.matching(identifier: "feed-image-view")
        XCTAssertTrue(imageViews.element.exists)
    }
}
