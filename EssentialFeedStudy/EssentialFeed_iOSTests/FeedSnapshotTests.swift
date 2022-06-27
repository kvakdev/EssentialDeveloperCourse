//
//  FeedSnapshotTests.swift
//  EssentialFeed_iOSTests
//
//  Created by Andre Kvashuk on 6/26/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed_iOS
@testable import EssentialFeed

class FeedSnapshotTests: XCTestCase {
    func test_sut_displaysEmptyFeed() {
        let sut = makeSUT()
        sut.display(stubs: emptyFeed())
        
        let snapshot = sut.takeSnapshot()
        record(snapshot: snapshot, named: "EMPTY_FEED")
    }
    
    func test_sut_displaysFeed() {
        let sut = makeSUT()
        sut.display(stubs: nonEmptyFeed())
        
        let snapShot = sut.takeSnapshot()
        record(snapshot: snapShot, named: "NON_EMPTY_FEED")
    }
    
    func test_sut_displaysErrorMessage() {
        let sut = makeSUT()
        sut.display(model: FeedErrorViewModel(message: "Missing connection"))
        
        let snapShot = sut.takeSnapshot()
        record(snapshot: snapShot, named: "ERROR_MESSAGE")
    }
    
    func test_sut_displaysMultiplesLinesErrorMessage() {
        let sut = makeSUT()
        sut.display(model: FeedErrorViewModel(message: "This is \na multiline \nerror message"))
        
        let snapShot = sut.takeSnapshot()
        record(snapshot: snapShot, named: "ERROR_MESSAGE_MULTILINE")
    }
    
    func test_sut_displaysFailedLoadedImageFeed() {
        let sut = makeSUT()
        sut.display(stubs: failedImageLoadStub())
        
        let snapShot = sut.takeSnapshot()
        record(snapshot: snapShot, named: "FAILED_IMAGE_LOADING")
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
    
    private func emptyFeed() -> [FeedImageStub] {
        return []
    }
    
    private func failedImageLoadStub() -> [FeedImageStub] {
        [FeedImageStub(description: "Description",
                       image: nil,
                       location: "Location"),
         
        FeedImageStub(description: "Description",
                      image: nil,
                      location: "New York Times Square")]
    }
    
    private func nonEmptyFeed() ->  [FeedImageStub] {
        [FeedImageStub(description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed ut mattis quam, id dapibus ipsum. Nam vitae orci massa. Cras vel magna ut purus placerat elementum quis sed ante. ",
                       image: UIImage.with(.red)),
         
        FeedImageStub(description: "Lorem orci massa. Cras vel magna ut purus placerat elementum quis sed ante. ",
                      image: UIImage.with(.blue),
                      location: "New York Times Square")]
    }
}

extension FeedViewController {
    func display(stubs: [FeedImageStub]) {
        let cellControllers: [FeedImageCellController] = stubs.compactMap {
            let controller = FeedImageCellController(delegate: $0)
            $0.cellController = controller
            
            return controller
        }
        self.display(model: cellControllers)
    }
}

class FeedImageStub: FeedImageCellControllerDelegate {
    weak var cellController: FeedImageCellController?
    let stubViewModel: FeedImageViewModel<UIImage>
    
    init(description: String?, image: UIImage?, location: String? = nil) {
        self.stubViewModel = FeedImageViewModel<UIImage>(description: description,
                                               location: location,
                                               isLocationHidden: location == nil,
                                               isLoading: false,
                                               image: image,
                                               isRetryVisible: image == nil)
    }
    
    func didRequestToLoadImage() {
        cellController?.display(model: stubViewModel)
    }
    
    func didCancelTask() {}
}

extension UIViewController {
    func takeSnapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.view.bounds)
        
        return renderer.image { action in
            self.view.layer.render(in: action.cgContext)
        }
    }
}

extension UIImage {
    static func with(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
