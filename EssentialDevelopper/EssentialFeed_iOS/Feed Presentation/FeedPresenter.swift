//
//  FeedPresenter.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/14/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation


import Foundation
import EssentialFeed

protocol FeedView {
    func display(feed: [FeedImage])
}

protocol LoaderView {
    func setLoader(visible: Bool)
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
        self.loaderView.setLoader(visible: true)
        
        self.loader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.view.display(feed: feed)
            }
            self?.loaderView.setLoader(visible: false)
        }
    }
}
