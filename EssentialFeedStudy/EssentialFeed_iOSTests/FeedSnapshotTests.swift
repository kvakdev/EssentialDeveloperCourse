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
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "EMPTY_FEED_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "EMPTY_FEED_light")
    }
    
    func test_sut_displaysFeed() {
        let sut = makeSUT()
        sut.display(stubs: nonEmptyFeed())
        
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "NON_EMPTY_FEED_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "NON_EMPTY_FEED_light")
    }
    
    func test_sut_displaysErrorMessage() {
        let sut = makeSUT()
        sut.display(model: FeedErrorViewModel(message: "Missing connection"))
   
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "ERROR_MESSAGE_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "ERROR_MESSAGE_light")
    }
    
    func test_sut_displaysMultiplesLinesErrorMessage() {
        let sut = makeSUT()
        sut.display(model: FeedErrorViewModel(message: "This is \na multiline \nerror message"))
  
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "ERROR_MESSAGE_MULTILINE_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "ERROR_MESSAGE_MULTILINE_light")
    }
    
    func test_sut_displaysFailedLoadedImageFeed() {
        let sut = makeSUT()
        sut.display(stubs: failedImageLoadStub())

        assert(snapshot: sut.snapshot(for: .iPhone8(style: .dark)), named: "FAILED_IMAGE_LOADING_dark")
        assert(snapshot: sut.snapshot(for: .iPhone8(style: .light)), named: "FAILED_IMAGE_LOADING_light")
        
    }
    
    private func snapshotURL(named name: String, in file: StaticString = #file) -> URL {
        URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("snapshots")
            .appendingPathComponent("\(name).png")
    }
    
    private func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) -> Data? {
        guard let data = snapshot.pngData() else {
            XCTFail("Failed to generate PNG data representation from snapshot", file: file, line: line)
            return nil
        }
        
        return data
    }
    
    func assert(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let imageData = makeSnapshotData(for: snapshot, file: file, line: line)
        let url = snapshotURL(named: name, in: file)
        
        do {
            let savedImageData = try Data(contentsOf: url)
            XCTAssertEqual(savedImageData, imageData, file: file, line: line)
            
        } catch let error {
            XCTFail("Unable to load image data for \(name) with error \(error)", file: file, line: line)
        }
    }
    
    func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let imageData = makeSnapshotData(for: snapshot, file: file, line: line)
        let url = snapshotURL(named: name, in: file)
        
        do {
            try FileManager.default.createDirectory(
                at: url.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )
            
            try imageData?.write(to: url)
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
    func snapshot(for configuration: SnapshotConfiguration) -> UIImage {
        return SnapshotWindow(configuration: configuration, root: self).snapshot()
    }
}

struct SnapshotConfiguration {
     let size: CGSize
     let safeAreaInsets: UIEdgeInsets
     let layoutMargins: UIEdgeInsets
     let traitCollection: UITraitCollection

     static func iPhone8(style: UIUserInterfaceStyle) -> SnapshotConfiguration {
         return SnapshotConfiguration(
             size: CGSize(width: 375, height: 667),
             safeAreaInsets: UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0),
             layoutMargins: UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16),
             traitCollection: UITraitCollection(traitsFrom: [
                 .init(forceTouchCapability: .available),
                 .init(layoutDirection: .leftToRight),
                 .init(preferredContentSizeCategory: .medium),
                 .init(userInterfaceIdiom: .phone),
                 .init(horizontalSizeClass: .compact),
                 .init(verticalSizeClass: .regular),
                 .init(displayScale: 2),
                 .init(displayGamut: .P3),
                 .init(userInterfaceStyle: style)
             ]))
     }
 }

private final class SnapshotWindow: UIWindow {
    private var configuration: SnapshotConfiguration = .iPhone8(style: .light)
    
    convenience init(configuration: SnapshotConfiguration, root: UIViewController) {
        self.init(frame: CGRect(origin: .zero, size: configuration.size))
        self.configuration = configuration
        self.layoutMargins = configuration.layoutMargins
        self.rootViewController = root
        self.isHidden = false
        root.view.layoutMargins = configuration.layoutMargins
    }
    
    override var safeAreaInsets: UIEdgeInsets {
        return configuration.safeAreaInsets
    }
    
    override var traitCollection: UITraitCollection {
        return UITraitCollection(traitsFrom: [super.traitCollection, configuration.traitCollection])
    }
    
    func snapshot() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        
        return renderer.image { action in
            self.layer.render(in: action.cgContext)
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
