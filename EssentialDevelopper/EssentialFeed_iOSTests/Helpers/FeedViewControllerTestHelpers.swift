//
//  FeedViewControllerTestHelpers.swift
//  EssentialFeed_iOSTests
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import EssentialFeed_iOS
import UIKit

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
    @discardableResult
    func simulateViewNotVisible(at index: Int) -> FeedImageCell {
        let cell = simulateViewIsVisible(at: index)!
        let delegate = self.tableView.delegate
        let indexPath = IndexPath(row: index, section: feedSection)
        delegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
        
        return cell
    }
    
    func simulateNearVisible(at index: Int) {
        let indexPath = IndexPath(row: index, section: feedSection)
        let ds = tableView.prefetchDataSource!
        ds.tableView(tableView, prefetchRowsAt: [indexPath])
    }
    
    func simulateViewNoLongerNearVisible(at index: Int) {
        simulateNearVisible(at: index)
        
        let indexPath = IndexPath(row: index, section: feedSection)
        let ds = tableView.prefetchDataSource!
        ds.tableView?(tableView, cancelPrefetchingForRowsAt: [indexPath])
    }
}
