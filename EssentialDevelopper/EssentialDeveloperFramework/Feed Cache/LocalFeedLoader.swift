//
//  LocalFeedLoader.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 6/5/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public final class LocalFeedLoader {
    public typealias ReceivedResult = Error?
    
    private let store: FeedStore
    private let timestamp: () -> Date
    
    public init(_ store: FeedStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.timestamp = timestamp
    }
    
    public func save(_ feedImages: [FeedImage], completion: @escaping (ReceivedResult) -> Void) {
        store.deleteCachedFeed() { [weak self] error in
            guard let self = self else { return }
            
            if let deletionError = error {
                completion(deletionError)
            } else {
                self.cache(feedImages, completion: completion)
            }
        }
    }
    
    public func load(_ completion: @escaping ([FeedImage]?, Error?) -> Void) {
        store.retrieve { result in
            switch result {
            case .success(let feed, let timestamp):
                if timestamp.timeIntervalSinceNow < -(7*24*60*60) {
                    completion([], nil)
                } else {
                    completion(feed.toModel(), nil)
                }
            case .failure(let error):
                completion(nil, error)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], completion: @escaping (ReceivedResult) -> Void) {
        self.store.insert(feed.toLocal(), timestamp: timestamp()) { [weak self] result in
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
