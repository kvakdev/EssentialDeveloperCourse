//
//  LocalFeeLoader.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 4/26/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public final class LocalFeedLoader {
    private let store: FeedStore
    private let timestamp: () -> Date
    
    public typealias SaveResult = Error?
    
    public enum Result {
        case success([FeedItem], Date)
        case failure(Error)
    }
    
    public init(store: FeedStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.timestamp = timestamp
    }
    
    public func save(_ items: [FeedItem], completion: @escaping (SaveResult) -> Swift.Void) {
        self.store.deleteCache { [weak self] error in
            guard let self = self else { return }
            
            if let error = error {
                completion(error)
            } else {
                self.cache(items: items.toLocal(), completion: completion)
            }
        }
    }
    
    private func cache(items: [LocalFeedItem], completion: @escaping (SaveResult) -> Void) {
        store.insert(items, timestamp: timestamp()) { [weak self] err in
            guard self != nil else { return }
            
            completion(err)
        }
    }
    
    public func retrieveFeed(completion: @escaping (Result) -> Swift.Void) {
        self.store.retrieve() { [unowned self] result in
            switch result {
            case .failure:
                completion(result)
            case .success(let feedItems, let timestamp):
                if self.isValidTimestamp(timestamp) {
                    completion(.success(feedItems, timestamp))
                }
            }
        }
    }
    
    private func isValidTimestamp(_ timestamp: Date) -> Bool {
        return timestamp.addingTimeInterval(7*24*60*60) > Date()
    }
    
}

public extension Array where Element == FeedItem {
    func toLocal() -> [LocalFeedItem] {
        return map { LocalFeedItem(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.imageURL) }
    }
}
