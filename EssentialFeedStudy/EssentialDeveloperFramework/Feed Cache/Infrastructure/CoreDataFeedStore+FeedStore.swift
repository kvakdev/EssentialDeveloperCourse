//
//  CoreDataFeedStore+FeedStore.swift
//  EssentialFeed
//
//  Created by Andre Kvashuk on 6/20/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

extension CoreDataFeedStore {
    
    public func deleteCachedFeed(completion: @escaping TransactionCompletion) {
        perform { context in
            completion(Result {
                try ManagedFeedCache.find(in: context).map(context.delete).map(context.save)
            })
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping TransactionCompletion) {
        perform { context in
            completion(Result {
                let cache = try ManagedFeedCache.newUniqueInstance(in: context)
                cache.timestamp = timestamp
                cache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
            })
        }
    }
    
    public func retrieve(_ completion: @escaping RetrieveCompletion) {
        perform { context in
            completion(Result {
                try ManagedFeedCache.find(in: context).map {
                    CachedFeed(feed: $0.localFeed,
                               timestamp: $0.timestamp)
                }
            })
        }
    }
    
}
