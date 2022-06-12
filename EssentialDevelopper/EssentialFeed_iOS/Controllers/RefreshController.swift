//
//  RefreshController.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit
import EssentialFeed

class RefreshController: NSObject {
    let loader: FeedLoader
    let onRefresh: ([FeedImage]) -> Void
    
    init(loader: FeedLoader, onRefresh: @escaping ([FeedImage]) -> Void) {
        self.loader = loader
        self.onRefresh = onRefresh
    }
    
    lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        
        return refreshControl
    }()
    
    @objc
    func load() {
        self.view.beginRefreshing()
        
        self.loader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh(feed)
            }
            self?.view.endRefreshing()
        }
    }
}
