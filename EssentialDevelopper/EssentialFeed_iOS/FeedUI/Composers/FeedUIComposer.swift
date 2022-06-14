//
//  FeedUIComposer.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed
import UIKit

public class FeedUIComposer {
    private init() {}
    
    public static func makeFeedViewController(loader: FeedLoader, imageLoader: FeedImageLoader) -> FeedViewController {
        
        let feedViewController = FeedViewController()
        
        let refreshController = RefreshController()
        let adapter = FeedViewControllerAdapter(feedViewController: feedViewController, imageLoader: imageLoader)
        let presenter = FeedPresenter(loader: loader, view: adapter, loaderView: VirtualWeakRefProxy(refreshController))
        
        feedViewController.refreshController = refreshController
        refreshController.presenter = presenter
        
        return feedViewController
    }
    
    private static func adaptFeedToFeedViewController(vc: FeedViewController, loader: FeedImageLoader) -> ([FeedImage]) -> Void {
        return { [weak vc] feed in
            vc?.tableModel = feed.map {
                let vm = FeedImageCellViewModel(model: $0, imageLoader: loader, transformer: UIImage.init)
                return FeedImageCellController(viewModel: vm)
            }
        }
    }
}

class FeedViewControllerAdapter: FeedView {
    weak var feedViewController: FeedViewController?
    let imageLoader: FeedImageLoader
    
    func display(model: FeedUIModel) {
        feedViewController?.tableModel = model.feed.map {
            let vm = FeedImageCellViewModel(model: $0, imageLoader: imageLoader, transformer: UIImage.init)
            return FeedImageCellController(viewModel: vm)
        }
    }

    
    init(feedViewController: FeedViewController, imageLoader: FeedImageLoader) {
        self.feedViewController = feedViewController
        self.imageLoader = imageLoader
    }
}

class VirtualWeakRefProxy<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension VirtualWeakRefProxy: FeedView where T: FeedView {
    func display(model: FeedUIModel) {
        object?.display(model: model)
    }
}

extension VirtualWeakRefProxy: LoaderView where T: LoaderView {
    func display(uiModel: FeedLoaderUIModel) {
        object?.display(uiModel: uiModel)
    }
}
