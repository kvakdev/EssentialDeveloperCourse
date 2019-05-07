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
    
    public enum LoadFeedResult {
        case success([FeedImage], Date)
        case failure(Error)
    }
    
    public init(store: FeedStore, timestamp: @escaping () -> Date) {
        self.store = store
        self.timestamp = timestamp
    }
    
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
    
    public func load(completion: @escaping (LoadFeedResult) -> Swift.Void) {
        self.store.retrieve() { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .failure:
                completion(result)
            case .success(let feed, let retrievedTimestamp):
                if LocalFeedValidationPolicy.isValidTimestamp(retrievedTimestamp, against: self.timestamp()) {
                    completion(.success(feed, retrievedTimestamp))
                } else {
                    self.store.deleteCache(completion: { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success([], retrievedTimestamp))
                        }
                    })
                }
            }
        }
    }
    
    private class LocalFeedValidationPolicy {
        static func isValidTimestamp(_ timestamp: Date, against date: Date) -> Bool {
            let expirationDate = timestamp.addingDays(7)
            
            let result = expirationDate >= date
            print("comparing \(expirationDate) >= \(date) result = \(result)")
            
            return result
        }
    }
}

public extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageUrl: $0.imageURL) }
    }
}

fileprivate extension Date {
    func addingDays(_ amount: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: amount), to: self)!
    }
    
    func addingSeconds(_ amount: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(second: amount), to: self)!
    }
}
