//
//  FeedPresentationAdapter.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/16/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed


class FeedPresentationAdapter: FeedViewControllerDelegate {
    let loader: FeedLoader
    var delegate: FeedLoadDelegate?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func didRequestFeedLoad() {
        delegate?.didStartLoadingFeed()

        loader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.delegate?.didCompleteLoading(with: feed)
            case .failure(let error):
                self?.delegate?.didCompleteLoadingWith(error: error)
            }
        }
    }
}

