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

protocol FeedLoadDelegate {
    func didStartLoadingFeed()
    func didCompleteLoading(with feed: [FeedImage])
    func didCompleteLoadingWith(error: Error)
}

final class FeedPresenter: FeedLoadDelegate {
    let view: FeedView
    let loaderView: LoaderView
    
    init(view: FeedView, loaderView: LoaderView) {
        self.view = view
        self.loaderView = loaderView
    }
    
    func didStartLoadingFeed() {
        self.loaderView.display(uiModel: FeedLoaderUIModel(isLoading: true))
    }
    
    func didCompleteLoading(with feed: [FeedImage]) {
        self.view.display(model: FeedUIModel(feed: feed))
        self.loaderView.display(uiModel: FeedLoaderUIModel(isLoading: false))
    }
    
    func didCompleteLoadingWith(error: Error) {
        self.loaderView.display(uiModel: FeedLoaderUIModel(isLoading: false))
    }
}
