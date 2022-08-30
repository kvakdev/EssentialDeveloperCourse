//
//  FeedViewAdapter.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/16/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeed_iOS
import UIKit

class FeedViewAdapter: FeedView {
    weak var feedViewController: FeedViewController?
    let imageLoader: FeedImageLoader
    
    func display(model: FeedViewModel) {
        feedViewController?.display(model: model.feed.map {
            let feedImageAdapter = FeedImageCompositionAdapter<VirtualWeakRefProxy<FeedImageCellController>, UIImage>(imageLoader: imageLoader, model: $0)
            let controller = FeedImageCellController(delegate: feedImageAdapter)
            let view = VirtualWeakRefProxy(controller)
            let presenter = FeedImageCellPresenter(view: view, transformer: UIImage.init)
            
            feedImageAdapter.presenter = presenter
            
            return controller
        })
    }

    init(feedViewController: FeedViewController, imageLoader: FeedImageLoader) {
        self.feedViewController = feedViewController
        self.imageLoader = imageLoader
    }
}
