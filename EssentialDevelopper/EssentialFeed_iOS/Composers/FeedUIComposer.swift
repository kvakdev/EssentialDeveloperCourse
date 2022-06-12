//
//  FeedUIComposer.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed

public class FeedUIComposer {
    private init() {}
    
    public static func makeFeedViewController(loader: FeedLoader, imageLoader: FeedImageLoader) -> FeedViewController {
        
        let feedViewController = FeedViewController()
        let refreshController = RefreshController(loader: loader, onRefresh: { [weak feedViewController] feed in
            feedViewController?.tableModel = feed.map {
                FeedImageCellController(model: $0, imageLoader: imageLoader)
            }
        })
        feedViewController.refreshController = refreshController
        
        return feedViewController
    }
}
