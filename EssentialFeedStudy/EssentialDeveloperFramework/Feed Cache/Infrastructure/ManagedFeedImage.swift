//
//  ManagedFeedImage.swift
//  EssentialFeed
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import CoreData


@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedFeedCache
    @NSManaged var data: Data?
    
    var local: LocalFeedImage {
        LocalFeedImage(id: id,
                       description: imageDescription,
                       location: location,
                       url: url)
    }
    
    static func images(from localFeed: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        return NSOrderedSet(array: localFeed.map { local in
            let managed = ManagedFeedImage(context: context)
            managed.id = local.id
            managed.imageDescription = local.description
            managed.location = local.location
            managed.url = local.url
            return managed
        })
    }
    
    static func first(with url: URL) throws -> ManagedFeedImage? {
        let fetchRequest = NSFetchRequest<ManagedFeedImage>(entityName: entity().name!)
        fetchRequest.predicate = NSPredicate(format: "%K = %@", argumentArray: [#keyPath(ManagedFeedImage.url), url])
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.fetchLimit = 1
        
        return try fetchRequest.execute().first
    }
}
