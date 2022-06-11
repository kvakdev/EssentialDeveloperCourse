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

class LoaderSpy: FeedLoader, FeedImageLoader {
    var completions = [(FeedLoader.Result) -> ()]()
    var imageLoadCompletions = [(url: URL, completion: (ImageLoadResult) -> ())]()
    var loadedURLs: [URL] {
        imageLoadCompletions.map { $0.url }
    }
    var cancelledUrls: [URL] = []
    
    var loadCount: Int {
        completions.count
    }
    
    private class FeedImageLoaderTaskSpy: FeedImageDataLoaderTask {
        let completion: () -> Void
        
        init(cancelCompletion: @escaping () -> Void) {
            self.completion = cancelCompletion
        }
        
        func cancel() {
            completion()
        }
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> ()) {
        completions.append(completion)
    }
    
    func complete(with feed: [FeedImage] = [], index: Int = 0) {
        completions[index](.success(feed))
    }
    
    func completeWithError(index: Int = 0) {
        completions[index](.failure(NSError(domain: "Loader spy error", code: 0)))
    }
    
    func loadImage(with url: URL, completion: @escaping (ImageLoadResult) -> Void) -> FeedImageDataLoaderTask {
        imageLoadCompletions.append((url: url, completion: completion))
        
        return FeedImageLoaderTaskSpy(cancelCompletion: { [weak self] in self?.cancelImageLoad(with: url) })
    }
    
    func cancelImageLoad(with url: URL) {
        cancelledUrls.append(url)
    }
    
    func completeImageLoadWithSuccess(_ data: Data = Data(), index: Int = 0) {
        imageLoadCompletions[index].completion(.success(data))
    }
    
    func completeImageLoadWithFailure(index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        imageLoadCompletions[index].completion(.failure(error))
    }
}

class FeedViewControllerTests: XCTestCase {
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
    
    private func makeImage(_ url: URL = URL(string: "http://any-url.com/0")!) -> FeedImage {
        FeedImage(id: UUID(), description: "description", location: nil, imageUrl: url)
    }
    
    private func assert(sut: FeedViewController, renders feed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        XCTAssertEqual(sut.numberOfRenderedImageViews, feed.count, file: file, line: line)
        
        feed.enumerated().forEach { index, image in
            assertViewAtIndex(in: sut, at: index, renders: image, file: file, line: line)
        }
    }
    
    private func assertViewAtIndex(in sut: FeedViewController, at index: Int, renders image: FeedImage, file: StaticString = #file, line: UInt = #line) {
        let view = sut.viewForIndex(index)
        
        guard let view = view  as? FeedImageCell else {
            XCTFail("expected \(FeedImageCell.self) got \(String(describing: view)) instead")
            return
        }
        
        XCTAssertEqual(view.locationText, image.location, file: file, line: line)
        XCTAssertEqual(view.descriptionText, image.description, file: file, line: line)
        XCTAssertEqual(view.isShowingLocation, image.location != nil, file: file, line: line)
    }
    
    private func makeSUT() -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader, imageLoader: loader)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(loader)
        
        return (sut, loader)
    }
}

extension FeedViewController {
    func simulaterUserInitiatedLoad() {
        self.refreshControl?.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        self.refreshControl?.isRefreshing == true
    }
    
    var numberOfRenderedImageViews: Int {
        return tableView.numberOfRows(inSection: feedSection)
    }
    
    func viewForIndex(_ index: Int) -> UITableViewCell {
        let indexPath = IndexPath(row: index, section: feedSection)
        let ds = tableView.dataSource!
        
        return ds.tableView(tableView, cellForRowAt: indexPath)
    }
    
    var feedSection: Int {
        return 0
    }
    
    @discardableResult
    func simulateViewIsVisible(at index: Int) -> FeedImageCell? {
        return viewForIndex(index) as? FeedImageCell
    }
    
    func simulateViewNotVisible(at index: Int) {
        let cell = simulateViewIsVisible(at: index)!
        let delegate = self.tableView.delegate
        let indexPath = IndexPath(row: index, section: feedSection)
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    func simulateNearVisible(at index: Int) {
        let indexPath = IndexPath(row: index, section: feedSection)
        let ds = tableView.prefetchDataSource!
        ds.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateViewNoLongerNearVisible(at index: Int) {
        let indexPath = IndexPath(row: index, section: feedSection)
        let ds = tableView.prefetchDataSource!
        ds.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
}

extension FeedImageCell {
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return imageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    var showsRetryAction: Bool {
        return retryButton.isHidden == false
    }
    
    func simulateRetryTap() {
        self.retryButton.simulateTap()
    }
}

extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}

extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
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
