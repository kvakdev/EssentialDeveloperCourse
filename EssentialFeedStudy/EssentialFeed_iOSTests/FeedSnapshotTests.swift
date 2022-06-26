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
        record(snapshot: snapshot, named: "EMPTY_FEED")
    }
    
    func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        guard let imageData = snapshot.pngData() else {
            XCTFail("Unable to convert image to data")
            return
        }
        
        let url = URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent(name)
        
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try imageData.write(to: url)
        } catch let error {
            XCTFail("Data failed to write to disc with error \(error)", file: file, line: line)
        }
        
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
