//
//  LocalFeeLoader.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 4/26/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public final class LocalFeedLoader: FeedLoaderProtocol {
    private let store: FeedStore
    private let timestamp: () -> Date
    private let policy: DateValidationProtocol
    
    public typealias SaveResult = Error?
    
    public typealias Result = FeedLoaderResult
    
    public init(store: FeedStore, timestamp: @escaping () -> Date, policy: DateValidationProtocol = LocalFeedValidationPolicy()) {
        self.store = store
        self.timestamp = timestamp
        self.policy = policy
    }
    
    private func isValid(_ date: Date) -> Bool {
        return policy.isValidTimestamp(date, against: self.timestamp())
    }
}
extension LocalFeedLoader {
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Swift.Void) {
        self.store.deleteCache { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                completion(error)
            } else {
                self.cache(feed: feed.toLocal(), completion: completion)
            }
        }
    }
    
    private func cache(feed: [LocalFeedImage], completion: @escaping (SaveResult) -> Void) {
        store.insert(feed, timestamp: timestamp()) { [weak self] err in
            guard self != nil else { return }
            
            completion(err)
        }
    }
}

extension LocalFeedLoader {
    public func load(completion: @escaping (Result) -> Swift.Void) {
        self.store.retrieve() { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case .found(let feed, let date) where self.isValid(date):
                completion(.success(feed.toModels()))
                
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [unowned self] result in
            switch result {
            case .failure:
                self.store.deleteCache { _ in }
                
            case .found(_, let timestamp) where !self.isValid(timestamp):
                self.store.deleteCache { _ in }
                
            case .empty, .found: break
            }
        }
    }
}

public extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.imageURL) }
    }
}

public extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.url) }
    }
}


