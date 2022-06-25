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
    }
}
