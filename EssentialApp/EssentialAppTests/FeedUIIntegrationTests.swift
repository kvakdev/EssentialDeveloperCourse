//
//  FeedViewControllerTests.swift
//  EssentialFeed_iOSTests
//
//  Created by Andre Kvashuk on 6/10/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeed_iOS
import EssentialApp

class FeedUIIntegrationTests: XCTestCase {
    
    func test_feedLoadError_showsMessageOnFeedViewController() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.completeWithError()
        
        let errorMessage = NSLocalizedString("FEED_LOADING_ERROR",
                                             tableName: "Feed",
                                             bundle: Bundle(for: FeedPresenter.self),
                                             value: "",
                                             comment: "")
        
        XCTAssertEqual(sut.errorMessage, errorMessage)
    }
    
    func test_loadFeed_isInvokedOnTheMainThread() {
        let (sut, loader) = makeSUT()
        let image = makeImage()
        let exp = expectation(description: "wait for load to complete")
        
        sut.loadViewIfNeeded()
        
        DispatchQueue.global().async {
            loader.complete(with: [image], index: 0)
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_loadFeedImage_isInvokedOnTheMainThread() {
        let (sut, loader) = makeSUT()
        let image = makeImage()
        let exp = expectation(description: "wait for load to complete")
        
        sut.loadViewIfNeeded()
        loader.complete(with: [image], index: 0)
        
        sut.simulateViewIsVisible(at: 0)
        DispatchQueue.global().async {
            loader.completeImageLoadWithSuccess()
            exp.fulfill()
        }
        
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func test_load_isCalledOnLoadAllEvents() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCount, 0, "expected no load when viewController is initialized")
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCount, 1, "expected first load on viewDidLoad")
        
        sut.simulaterUserInitiatedLoad()
        XCTAssertEqual(loader.loadCount, 2, "expected second load on user initiated update")
        
        sut.simulaterUserInitiatedLoad()
        XCTAssertEqual(loader.loadCount, 3, "expected third load on user initiated update")
    }
    
    func test_loadingIndicator_isLoadingOnAllLoadEventsAndStopsWhenCompletes() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loader to load when load is in progress")
        
        sut.simulaterUserInitiatedLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loader to load when load is in progress")
        
        loader.complete(with: [], index: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected no loader to load when load completed")
        
        sut.simulaterUserInitiatedLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator, "Expected loader to load when load is in progress")
        
        loader.completeWithError(index: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator, "Expected loader to hide when load completes with an error")
    }
    
    func test_view_rendersFeedImagesOnTheScreen() {
        let (sut, loader) = makeSUT()
        
        let image0 = FeedImage(id: UUID(), description: "description", location: nil, imageUrl: URL(string: "http://any-url.com")!)
        let image1 = FeedImage(id: UUID(), description: nil, location: nil, imageUrl: URL(string: "http://any-url.com/1")!)
        let image2 = FeedImage(id: UUID(), description: "description2", location: "location2", imageUrl: URL(string: "http://any-url.com/2")!)
        let image3 = FeedImage(id: UUID(), description: nil, location: "location3", imageUrl: URL(string: "http://any-url.com/3")!)
        let feed = [image0, image1, image2, image3]
        
        //triangulate with 0 items, 1 item and multiple items
        assert(sut: sut, renders: [])
        sut.loadViewIfNeeded()
        loader.complete(with: [image0], index: 0)
        assert(sut: sut, renders: [image0])
        
        sut.simulaterUserInitiatedLoad()
        loader.complete(with: feed, index: 1)
        assert(sut: sut, renders: feed)
    }
    
    func test_error_doesNotAlterCurrentState() {
        let (sut, loader) = makeSUT()
        let image0 = FeedImage(id: UUID(), description: "description", location: nil, imageUrl: URL(string: "http://any-url.com")!)
        sut.loadViewIfNeeded()
        loader.complete(with: [image0], index: 0)
        assert(sut: sut, renders: [image0])
        
        sut.simulaterUserInitiatedLoad()
        loader.completeWithError(index: 1)
        
        assert(sut: sut, renders: [image0])
    }
    
    func test_loadImage_isTriggeredWhenViewIsNearVisible() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(URL(string: "http://any-url.com/0")!)
        let image1 = makeImage(URL(string: "http://any-url.com/1")!)
        sut.loadViewIfNeeded()
        
        loader.complete(with: [image0, image1], index: 0)
        XCTAssertEqual(loader.loadedURLs, [])
        
        sut.simulateViewIsVisible(at: 0)
        XCTAssertEqual(loader.loadedURLs, [image0.url])
        
        sut.simulateViewIsVisible(at: 1)
        XCTAssertEqual(loader.loadedURLs, [image0.url, image1.url])
    }
    
    func test_loadImageRequest_cancelsAfterViewisNotVisibleAnymore() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(URL(string: "http://any-url.com/0")!)
        let image1 = makeImage(URL(string: "http://any-url.com/1")!)
        sut.loadViewIfNeeded()
        
        loader.complete(with: [image0, image1], index: 0)
        XCTAssertEqual(loader.loadedURLs, [])
        
        sut.simulateViewNotVisible(at: 0)
        XCTAssertEqual(loader.cancelledUrls, [image0.url])
    }
    
    func test_imageViews_showLoadIndicatorWhenImageURLIsLoading() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(URL(string: "http://any-url.com/0")!)
        let image1 = makeImage(URL(string: "http://any-url.com/1")!)
        
        sut.loadViewIfNeeded()
        loader.complete(with: [image0, image1], index: 0)
        
        let view0 = sut.simulateViewIsVisible(at: 0)
        let view1 = sut.simulateViewIsVisible(at: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, true)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)
        
        loader.completeImageLoadWithSuccess()
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, true)
        
        loader.completeImageLoadWithFailure(index: 1)
        XCTAssertEqual(view0?.isShowingImageLoadingIndicator, false)
        XCTAssertEqual(view1?.isShowingImageLoadingIndicator, false)
    }
    
    func test_imageViews_renderImagesOnSuccessfulLoad() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(URL(string: "http://any-url.com/0")!)
        let image1 = makeImage(URL(string: "http://any-url.com/1")!)
        let loadedImageData0 = UIImage.with(.red).pngData()!
        let loadedImageData1 = UIImage.with(.blue).pngData()!
        
        sut.loadViewIfNeeded()
        loader.complete(with: [image0, image1], index: 0)
        
        let view0 = sut.simulateViewIsVisible(at: 0)
        let view1 = sut.simulateViewIsVisible(at: 1)
        XCTAssertEqual(view1?.renderedImage, nil)
        XCTAssertEqual(view1?.renderedImage, nil)
        
        loader.completeImageLoadWithSuccess(loadedImageData0, index: 0)
        XCTAssertEqual(view0?.renderedImage, loadedImageData0)
        XCTAssertEqual(view1?.renderedImage, nil)
        
        loader.completeImageLoadWithSuccess(loadedImageData1, index: 1)
        XCTAssertEqual(view0?.renderedImage, loadedImageData0)
        XCTAssertEqual(view1?.renderedImage, loadedImageData1)
    }
    
    func test_view_showRetryButtonOnLoadError() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(URL(string: "http://any-url.com/0")!)
        let image1 = makeImage(URL(string: "http://any-url.com/1")!)
        let loadedImageData0 = UIImage.with(.red).pngData()!
        let loadedImageData1 = UIImage.with(.blue).pngData()!
        
        sut.loadViewIfNeeded()
        loader.complete(with: [image0, image1], index: 0)
        
        let view0 = sut.simulateViewIsVisible(at: 0)
        let view1 = sut.simulateViewIsVisible(at: 1)
        
        XCTAssertEqual(view0?.showsRetryAction, false, "Expected no retry action for first view while loading first image")
        XCTAssertEqual(view1?.showsRetryAction, false, "Expected no retry action for first view while loading second image")
        loader.completeImageLoadWithSuccess(loadedImageData0, index: 0)
        loader.completeImageLoadWithFailure(index: 1)
        
        XCTAssertEqual(view0?.showsRetryAction, false, "Expected no retry action for first view after loading image successfuly")
        XCTAssertEqual(view1?.showsRetryAction, true, "Expected retry action for second view after failure to load second image")
        
        loader.completeImageLoadWithSuccess(loadedImageData1, index: 1)
        XCTAssertEqual(view0?.showsRetryAction, false,"Expected no retry action for first view after loading image successfuly")
        XCTAssertEqual(view1?.showsRetryAction, false, "Expected no retry action for second view after loading image successfuly")
    }
    
    func test_onRetry_triggersImageLoading() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(URL(string: "http://any-url.com/0")!)
        let image1 = makeImage(URL(string: "http://any-url.com/1")!)
        
        sut.loadViewIfNeeded()
        loader.complete(with: [image0, image1], index: 0)
        
        let view0 = sut.simulateViewIsVisible(at: 0)
        let view1 = sut.simulateViewIsVisible(at: 1)
        XCTAssertEqual(loader.loadedURLs, [image0.url, image1.url])
        loader.completeImageLoadWithFailure(index: 0)
        view0?.simulateRetryTap()
        XCTAssertEqual(loader.loadedURLs, [image0.url, image1.url, image0.url])
        view1?.simulateRetryTap()
        XCTAssertEqual(loader.loadedURLs, [image0.url, image1.url, image0.url, image1.url])
    }
    
    func test_feedImageViewRetryButton_isVisibleOnInvalidImageData() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        loader.complete(with: [makeImage()], index: 0)
        
        let view = sut.simulateViewIsVisible(at: 0)
        XCTAssertEqual(view?.showsRetryAction, false, "Expected no retry action while loading image")
        
        let invalidImageData = Data("invalid image data".utf8)
        loader.completeImageLoadWithSuccess(invalidImageData)
        XCTAssertEqual(view?.showsRetryAction, true, "Expected retry action once image loading completes with invalid image data")
    }
    
    func test_imageIsPrefetched_whenViewIsNearVisible() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(URL(string: "http://any-url.com/0")!)
        let image1 = makeImage(URL(string: "http://any-url.com/1")!)
        
        sut.loadViewIfNeeded()
        loader.complete(with: [image0, image1], index: 0)
        
        XCTAssertEqual(loader.loadedURLs, [])
        sut.simulateNearVisible(at: 0)
        XCTAssertEqual(loader.loadedURLs, [image0.url])
        
        sut.simulateNearVisible(at: 1)
        XCTAssertEqual(loader.loadedURLs, [image0.url, image1.url])
    }
    
    func test_imagePrefetchingIsCancelled_whenViewIsNotNearVisibleAnyMore() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(URL(string: "http://any-url.com/0")!)
        let image1 = makeImage(URL(string: "http://any-url.com/1")!)
        
        sut.loadViewIfNeeded()
        loader.complete(with: [image0, image1], index: 0)
        
        XCTAssertEqual(loader.cancelledUrls, [])
        
        sut.simulateViewNoLongerNearVisible(at: 0)
        XCTAssertEqual(loader.cancelledUrls, [image0.url])
        
        sut.simulateViewNoLongerNearVisible(at: 1)
        XCTAssertEqual(loader.cancelledUrls, [image0.url, image1.url])
    }
    
    func test_displays_emptyFeedAfterNonEmptyFeed() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage(URL(string: "http://any-url.com/0")!)
        let image1 = makeImage(URL(string: "http://any-url.com/1")!)
        
        sut.loadViewIfNeeded()
        loader.complete(with: [image0, image1], index: 0)
        assert(sut: sut, renders: [image0, image1])
        
        sut.simulaterUserInitiatedLoad()
        loader.complete(with: [], index: 1)
        
        sut.tableView.layoutIfNeeded()
        RunLoop.main.run(until: Date())
        
        assert(sut: sut, renders: [])
    }
    
    func test_feedImageCell_isNotConfiguredAfterDissapearing() {
        let (sut, loader) = makeSUT()
        let image0 = makeImage()
        sut.loadViewIfNeeded()
        loader.complete(with: [image0], index: 0)
        let cell = sut.simulateViewNotVisible(at: 0)
        loader.completeImageLoadWithSuccess(UIImage.with(.red).pngData()!, index: 0)
        
        XCTAssertNil(cell.renderedImage, "Expected image to be nil after cell goes off screen")
    }
    
}

// MARK: - TestHelpers
extension FeedUIIntegrationTests {
    
    private func makeImage(_ url: URL = URL(string: "http://any-url.com/0")!) -> FeedImage {
        FeedImage(id: UUID(), description: "description", location: nil, imageUrl: url)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedUIComposer.makeFeedViewController(loader: loader, imageLoader: loader)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(loader, file: file, line: line)
        
        return (sut, loader)
    }
}
