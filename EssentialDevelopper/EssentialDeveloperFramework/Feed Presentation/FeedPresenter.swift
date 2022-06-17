//
//  FeedPresenter.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation


public struct FeedUIModel {
    public let feed: [FeedImage]
}



public protocol LoaderView {
    func display(uiModel: FeedLoaderUIModel)
}

public protocol FeedView {
    func display(model: FeedUIModel)
}

public class FeedPresenter {
    private let view: FeedView
    private let loaderView: LoaderView
    
    private let feedLoadingError: String =
        NSLocalizedString("FEED_LOADING_ERROR",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          value: "",
                          comment: "error after feed loading")
    
    public static var title: String {
        NSLocalizedString("FEED_TITLE_VIEW",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          value: "",
                          comment: "Title for feed screen")
    }
    
    public init(view: FeedView, loaderView: LoaderView) {
        self.view = view
        self.loaderView = loaderView
    }
    
    public func didStartLoadingFeed() {
        self.loaderView.display(uiModel: .loading)
    }
    
    public func didCompleteLoading(with feed: [FeedImage]) {
        self.view.display(model: FeedUIModel(feed: feed))
        self.loaderView.display(uiModel: .noError)
    }
    
    public func didCompleteLoadingWith(error: Error) {
        self.loaderView.display(uiModel: .loadingError(feedLoadingError))
    }
}
