//
//  FeedSnapshotTests.swift
//  EssentialFeed_iOSTests
//
//  Created by Andre Kvashuk on 6/26/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed_iOS

class FeedSnapshotTests: XCTestCase {
    func test_sut_displaysEmptyFeed() {
        let sut = makeSUT()
        sut.display(model: emptyFeed())
        
        let snapshot = sut.takeSnapshot()
    }
    
    private func makeSUT() -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let sb = UIStoryboard(name: "Feed", bundle: bundle)
        let feedViewController = sb.instantiateInitialViewController() as! FeedViewController
        feedViewController.loadViewIfNeeded()
        
        return feedViewController
    }
    
    private func emptyFeed() -> [FeedImageCellController] {
        return []
    }
}

extension UIViewController {
    func takeSnapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.view.bounds)
        
        return renderer.image { action in
            self.view.layer.render(in: action.cgContext)
        }
    }
}
