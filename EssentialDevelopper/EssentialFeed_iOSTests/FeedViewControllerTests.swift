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

class LoaderSpy: FeedLoader {
    var completions = [(FeedLoader.Result) -> ()]()
    
    var loadCount: Int {
        completions.count
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
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        sut.simulaterUserInitiatedLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.complete()
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulaterUserInitiatedLoad()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.complete()
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_view_rendersFeedImagesOnTheScreen() {
        let (sut, loader) = makeSUT()
        
        let image0 = FeedImage(id: UUID(), description: "description", location: nil, imageUrl: URL(string: "http://any-url.com")!)
        let image1 = FeedImage(id: UUID(), description: nil, location: nil, imageUrl: URL(string: "http://any-url.com/1")!)
        let image2 = FeedImage(id: UUID(), description: "description2", location: "location2", imageUrl: URL(string: "http://any-url.com/2")!)
        let image3 = FeedImage(id: UUID(), description: nil, location: "location3", imageUrl: URL(string: "http://any-url.com/3")!)
        //triangulate with 0 items, 1 item and multiple items
        assert(sut: sut, renders: [])
        sut.loadViewIfNeeded()
        loader.complete(with: [image0], index: 0)
        assert(sut: sut, renders: [image0])
        
        sut.simulaterUserInitiatedLoad()
        let feed = [image0, image1, image2, image3]
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
        let sut = FeedViewController(loader: loader)
        
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
    
    func viewForIndex(_ index: Int) -> UITableViewCell? {
        let indexPath = IndexPath(row: index, section: feedSection)
        let ds = tableView.dataSource
        
        return ds?.tableView(tableView, cellForRowAt: indexPath)
    }
    
    var feedSection: Int {
        return 0
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
