//
//  CodableFeedStore.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 5/8/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public class CodableFeedStore {
    private struct FeedCache: Codable {
        let feed: [LocalFeedImage]
        let timestamp: Date
    }
    private let storeUrl: URL
    
    public init(storeUrl: URL) {
        self.storeUrl = storeUrl
    }
    
    public func retrieve(completion: @escaping (FeedRetrieveResult) -> Swift.Void) {
        guard let data = try? Data(contentsOf: storeUrl) else {
            return completion(.empty)
        }
        
        do {
            let cache = try JSONDecoder().decode(FeedCache.self, from: data)
            completion(.found(feed: cache.feed, timestamp: cache.timestamp))
        } catch {
            completion(.failure(error))
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCallback) {
        do {
            let encoder = JSONEncoder()
            let cache = FeedCache(feed: feed, timestamp: timestamp)
            let data = try encoder.encode(cache)
            
            try data.write(to: storeUrl, options: .atomic)
            completion(nil)
        } catch {
            completion(error)
        }
    }
    
    public func deleteCache(completion: @escaping FeedStore.DeletionCallback) {
        do {
            try FileManager.default.removeItem(at: self.storeUrl)
            completion(nil)
        } catch {
            completion(error)
        }
    }
}
