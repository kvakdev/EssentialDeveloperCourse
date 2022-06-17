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
    let errorMessage: String?
}

protocol LoaderView {
    func display(uiModel: FeedLoaderUIModel)
}

protocol FeedLoadDelegate {
    func didStartLoadingFeed()
    func didCompleteLoading(with feed: [FeedImage])
    func didCompleteLoadingWith(error: Error)
}

public final class FeedPresenter: FeedLoadDelegate {
    let view: FeedView
    let loaderView: LoaderView
    
    init(view: FeedView, loaderView: LoaderView) {
        self.view = view
        self.loaderView = loaderView
    }
    
    static var title: String {
        NSLocalizedString("FEED_TITLE_VIEW",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          value: "",
                          comment: "Title for feed screen")
    }
    
    static var feedLoadingError: String {
        NSLocalizedString("FEED_LOADING_ERROR",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          value: "",
                          comment: "error after feed loading")
    }
    
    func didStartLoadingFeed() {
        self.loaderView.display(uiModel: FeedLoaderUIModel(isLoading: true, errorMessage: nil))
    }
    
    func didCompleteLoading(with feed: [FeedImage]) {
        self.view.display(model: FeedUIModel(feed: feed))
        self.loaderView.display(uiModel: FeedLoaderUIModel(isLoading: false, errorMessage: nil))
    }
    
    func didCompleteLoadingWith(error: Error) {
        self.loaderView.display(uiModel: FeedLoaderUIModel(isLoading: false, errorMessage: Self.feedLoadingError))
    }
}
