//
//  CoreDataFeedStore.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import CoreData

public class CoreDataFeedStore: FeedStore {
    private class ManagedCache: NSManagedObject {
         @NSManaged var timestamp: Date
         @NSManaged var feed: NSOrderedSet
     }

     private class ManagedFeedImage: NSManagedObject {
         @NSManaged var id: UUID
         @NSManaged var imageDescription: String?
         @NSManaged var location: String?
         @NSManaged var url: URL
         @NSManaged var cache: ManagedCache
     }
    
    public init() {
        
    }
    
    public func deleteCachedFeed(completion: @escaping TransactionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping TransactionCompletion) {
        
    }
    
    public func retrieve(_ completion: @escaping RetrieveCompletion) {
        completion(.empty)
    }
}
