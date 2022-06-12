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
        let onFeedLoad = adaptFeedToFeedViewController(vc: feedViewController, loader: imageLoader)
        let refreshViewModel = RefreshViewModel(loader: loader, onFeedLoad: onFeedLoad)
        let refreshController = RefreshController(viewModel: refreshViewModel)
        
        feedViewController.refreshController = refreshController
        
        return feedViewController
    }
    
    private static func adaptFeedToFeedViewController(vc: FeedViewController, loader: FeedImageLoader) -> ([FeedImage]) -> Void {
        return { [weak vc] feed in
            vc?.tableModel = feed.map {
                FeedImageCellController(model: $0, imageLoader: loader)
            }
        }
    }
}
