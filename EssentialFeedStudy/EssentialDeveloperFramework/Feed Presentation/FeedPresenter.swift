//
//  FeedPresenter.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public protocol LoaderView {
    func display(uiModel: FeedLoaderViewModel)
}

public protocol FeedView {
    func display(model: FeedViewModel)
}

public protocol ErrorView {
    func display(model: FeedErrorViewModel)
}

public protocol FeedLoadDelegate {
    func didStartLoadingFeed()
    func didCompleteLoading(with feed: [FeedImage])
    func didCompleteLoadingWith(error: Error)
}


public class FeedPresenter: FeedLoadDelegate {
    private let view: FeedView
    private let loaderView: LoaderView
    private let errorView: ErrorView
    
  
    
    public init(view: FeedView, loaderView: LoaderView, errorView: ErrorView) {
        self.view = view
        self.loaderView = loaderView
        self.errorView = errorView
    }
    
    public func didStartLoadingFeed() {
        self.loaderView.display(uiModel: .loading)
        self.errorView.display(model: .noError)
    }
    
    public func didCompleteLoading(with feed: [FeedImage]) {
        self.view.display(model: FeedViewModel(feed: feed))
        self.loaderView.display(uiModel: .notLoading)
        self.errorView.display(model: .noError)
    }
    
    public func didCompleteLoadingWith(error: Error) {
        self.loaderView.display(uiModel: .notLoading)
        self.errorView.display(model: .feedLoadingError)
    }
}

public extension FeedPresenter {
    static var title: String {
        NSLocalizedString("FEED_TITLE_VIEW",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          value: "",
                          comment: "Title for feed screen")
    }
}
