//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
    
    private let container: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    
    public init(bundle: Bundle = .main, storeURL: URL) throws {
        try self.container = NSPersistentContainer.load(with: "FeedStore", in: bundle, storeURL: storeURL)
       
        backgroundContext = self.container.newBackgroundContext()
    }
    
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
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.backgroundContext
        context.perform { action(context) }
    }
}
