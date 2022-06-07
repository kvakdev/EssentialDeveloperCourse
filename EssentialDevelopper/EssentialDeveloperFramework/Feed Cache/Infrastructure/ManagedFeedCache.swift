//
//  ManagedFeedCache.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import CoreData


@objc(ManagedFeedCache)
class ManagedFeedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
    
    var localFeed: [LocalFeedImage] {
        feed
            .compactMap { $0 as? ManagedFeedImage }
            .map { $0.local }
    }
    
    static func find(in context: NSManagedObjectContext) throws -> ManagedFeedCache? {
        let request = NSFetchRequest<ManagedFeedCache>(entityName: "ManagedFeedCache")
        request.returnsObjectsAsFaults = false
        
        return try context.fetch(request).first
    }
    
    static func newUniqueInstance(in context: NSManagedObjectContext) throws -> ManagedFeedCache {
        try find(in: context).map(context.delete)
        return ManagedFeedCache(context: context)
        
    }
}
