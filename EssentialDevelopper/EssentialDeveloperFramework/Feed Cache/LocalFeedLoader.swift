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
    public typealias Result = FeedLoaderResult
    
    private let store: FeedStore
    private let currentDate: () -> Date
    private var maxAgeInDays: Int = 7
    
    
    public init(_ store: FeedStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.currentDate = timestamp
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
    
    public func load(_ completion: @escaping (Result) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let feed, let timestamp):
                if self.validate(timestamp) {
                    completion(.success(feed.toModel()))
                } else {
                    completion(.success([]))
                }
            case .failure(let error):
                self.store.deleteCachedFeed(completion: { _ in })
                completion(.failure(error))
            }
        }
    }
    
    public func validateCache() {
        store.retrieve() { [unowned self] result in
            switch result {
            case .success(_, let timestamp):
                if !self.validate(timestamp) {
                    self.store.deleteCachedFeed(completion: { _ in  })
                }
            case .failure:
                self.store.deleteCachedFeed(completion: { _ in })
            }
        }
    }
    
    private func validate(_ timestamp: Date) -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        guard let maxCachedAge = calendar.date(byAdding: .day, value: maxAgeInDays, to: timestamp) else {
            return false
        }
        
        return currentDate() < maxCachedAge
    }
    
    private func cache(_ feed: [FeedImage], completion: @escaping (ReceivedResult) -> Void) {
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
