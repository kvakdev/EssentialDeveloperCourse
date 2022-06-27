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
    
    private func makeSnapshotURL(named name: String, in file: StaticString = #file) -> URL {
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
        let snapshotData = makeSnapshotData(for: snapshot, file: file, line: line)
        let url = makeSnapshotURL(named: name, in: file)
        
        guard let savedImageData = try? Data(contentsOf: url) else {
            XCTFail("Unable to load image data for \(name)", file: file, line: line)
            return
        }
        let isMatch = savedImageData == snapshotData
        
        if !isMatch {
            let temporarySnapshotURL = URL(
                fileURLWithPath: NSTemporaryDirectory(),
                isDirectory: true).appendingPathComponent(url.lastPathComponent)
            
            try? snapshotData?.write(to: temporarySnapshotURL)
            
            XCTFail("New snapshot does not match stored snapshot. New snapshot URL: \(temporarySnapshotURL), Stored snapshot URL: \(url)", file: file, line: line)
        }
    }
    
    func record(snapshot: UIImage, named name: String, file: StaticString = #file, line: UInt = #line) {
        let imageData = makeSnapshotData(for: snapshot, file: file, line: line)
        let url = makeSnapshotURL(named: name, in: file)
        
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

