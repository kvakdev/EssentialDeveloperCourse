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

class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefresh()
        load()
    }
    
    func setupRefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
        self.refreshControl?.beginRefreshing()
    }
    
    @objc
    func load() {
        self.loader?.load() { [weak self] _ in
            self?.refreshControl?.endRefreshing()
        }
    }
}

class LoaderSpy: FeedLoader {
    var completions = [(FeedLoader.Result) -> ()]()

    var loadCount: Int {
        completions.count
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> ()) {
        completions.append(completion)
    }
    
    func complete(index: Int = 0) {
        completions[index](.failure(NSError()))
    }
}

class FeedViewControllerTests: XCTestCase {
    func test_load_isNotIvokedOnInit() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCount, 0)
    }
    
    func test_load_isInvokedOnViewDidLoad() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCount, 1)
    }
    
    func test_pullToRefresh_loadsFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCount, 2)
        
        sut.refreshControl?.simulatePullToRefresh()
        XCTAssertEqual(loader.loadCount, 3)
    }
    
    func test_loadingIndicator_isLoading() {
        let (sut, _) = makeSUT()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_loadingIndicator_isLoadingOnPullToRefresh() {
        let (sut, _) = makeSUT()
        
        sut.refreshControl?.simulatePullToRefresh()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, true)
    }
    
    func test_loadingIndicators_hidesAfterFirstLoadCompletes() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        loader.complete()
        
        XCTAssertEqual(sut.refreshControl?.isRefreshing, false)
    }
    
    private func makeSUT() -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(loader)
        
        return (sut, loader)
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
