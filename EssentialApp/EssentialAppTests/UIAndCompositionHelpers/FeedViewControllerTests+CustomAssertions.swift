//
//  FeedViewControllerTests+CustomAssertions.swift
//  EssentialFeed_iOSTests
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeed_iOS
import XCTest

extension FeedUIIntegrationTests {
    
    func assert(sut: FeedViewController, renders feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        sut.tableView.layoutIfNeeded()
        RunLoop.main.run(until: Date())
        
        XCTAssertEqual(sut.numberOfRenderedImageViews, feed.count, file: file, line: line)
        
        feed.enumerated().forEach { index, image in
            assertViewAtIndex(in: sut, at: index, renders: image, file: file, line: line)
        }
    }
    
    func assertViewAtIndex(in sut: FeedViewController, at index: Int, renders image: FeedImage, file: StaticString = #file, line: UInt = #line) {
        let view = sut.viewForIndex(index)
        
        guard let view = view  as? FeedImageCell else {
            XCTFail("expected \(FeedImageCell.self) got \(String(describing: view)) instead")
            return
        }
        
        XCTAssertEqual(view.locationText, image.location, file: file, line: line)
        XCTAssertEqual(view.descriptionText, image.description, file: file, line: line)
        XCTAssertEqual(view.isShowingLocation, image.location != nil, file: file, line: line)
    }
    
}
