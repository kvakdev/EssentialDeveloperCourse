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
        XCTAssertEqual(sut.modelsCount, 0)
        sut.loadViewIfNeeded()
        loader.complete(with: [image0], index: 0)
        XCTAssertEqual(sut.modelsCount, 1)
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
    
    var modelsCount: Int {
        return tableModel?.count ?? 0
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
