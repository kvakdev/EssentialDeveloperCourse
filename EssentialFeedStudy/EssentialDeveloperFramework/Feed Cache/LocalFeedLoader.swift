//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Andre Kvashuk on 6/5/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public final class LocalFeedLoader: FeedLoader {
    public typealias SaveResult = Result<Void, Error>
    public typealias LoadResult = FeedLoader.Result
    public typealias ValidationResult = Result<Void, Error>
    
    private let store: FeedStore
    private let currentDate: () -> Date
    
    
    public init(_ store: FeedStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.currentDate = timestamp
    }
    
    public func save(_ feedImages: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        store.deleteCachedFeed() { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                self.cache(feedImages, completion: completion)
            case .failure:
                completion(result)
            }
        }
    }
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let feedCache):
                if let cache = feedCache, FeedCachePolicy.validate(cache.timestamp, against: self.currentDate()) {
                    completion(.success(cache.feed.toModel()))
                } else {
                    completion(.success([]))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    public func validateCache(completion: @escaping Closure<ValidationResult>) {
        store.retrieve() { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(.some(let feedCache)) where !FeedCachePolicy.validate(feedCache.timestamp, against: self.currentDate()):
                    self.store.deleteCachedFeed(completion: completion)
            case .success:
                completion(.success(()))
            case .failure:
                self.store.deleteCachedFeed(completion: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void) {
        self.store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] result in
            guard self != nil else { return }
            
            completion(result)
        }
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        compactMap { LocalFeedImage(id: $0.id,
                                    description: $0.description,
                                    location: $0.location,
                                    url: $0.url)
        }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModel() -> [FeedImage] {
        compactMap { FeedImage(id: $0.id,
                               description: $0.description,
                               location: $0.location,
                               imageUrl: $0.url)
        }
    }
}
