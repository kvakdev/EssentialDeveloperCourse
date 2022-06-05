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
