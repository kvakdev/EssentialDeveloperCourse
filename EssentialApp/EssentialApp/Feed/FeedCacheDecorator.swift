//
//  FeedCacheDecorator.swift
//  EssentialApp
//
//  Created by Andre Kvashuk on 6/25/22.
//

import Foundation
import EssentialFeed

public class FeedCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> ()) {
        decoratee.load() { [weak self] result in
            completion(result.map { feed in
                self?.saveIgnoringResult(feed)
                
                return feed
            })
        }
    }
    
    private func saveIgnoringResult(_ feed: [FeedImage]) {
        cache.save(feed, completion: { _ in })
    }
}
