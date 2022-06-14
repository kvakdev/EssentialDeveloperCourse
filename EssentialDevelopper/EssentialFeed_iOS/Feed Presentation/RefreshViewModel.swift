//
//  RefreshViewModel.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed

class RefreshViewModel {
    let loader: FeedLoader
    var onIsLoadingChange: ((Bool) -> Void)?
    var onFeedLoad: (([FeedImage]) -> Void)?
    
    init(loader: FeedLoader, onFeedLoad: @escaping ([FeedImage]) -> Void) {
        self.loader = loader
        self.onFeedLoad = onFeedLoad
    }
    
    @objc
    func loadFeed() {
        onIsLoadingChange?(true)
        
        self.loader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.onFeedLoad?(feed)
            }
            self?.onIsLoadingChange?(false)
        }
    }
}
