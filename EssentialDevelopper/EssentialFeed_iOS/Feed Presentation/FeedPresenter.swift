//
//  FeedPresenter.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/14/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed

struct FeedUIModel {
    let feed: [FeedImage]
}

protocol FeedView {
    func display(model: FeedUIModel)
}

struct FeedLoaderUIModel {
    let isLoading: Bool
}

protocol LoaderView {
    func display(uiModel: FeedLoaderUIModel)
}

final class FeedPresenter {
    let loader: FeedLoader
    let view: FeedView
    let loaderView: LoaderView
    
    init(loader: FeedLoader, view: FeedView, loaderView: LoaderView) {
        self.loader = loader
        self.view = view
        self.loaderView = loaderView
    }
    
    func loadFeed() {
        self.loaderView.display(uiModel: FeedLoaderUIModel(isLoading: true))
        
        self.loader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.view.display(model: FeedUIModel(feed: feed))
            }
            self?.loaderView.display(uiModel: FeedLoaderUIModel(isLoading: false))
        }
    }
}
