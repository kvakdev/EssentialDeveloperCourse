//
//  ManagedFeedImage.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/6/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import CoreData

@objc(ManagedFeedImage)
class ManagedFeedImage: NSManagedObject {
    @NSManaged internal var id: UUID
    @NSManaged internal var imageDescription: String?
    @NSManaged internal var location: String?
    @NSManaged internal var url: URL
}


extension ManagedFeedImage {
    func toManaged(from images: [LocalFeedImage], in context: NSManagedObjectContext) -> NSOrderedSet {
        
        return NSOrderedSet(array: images.compactMap { image in
            let managed = ManagedFeedImage(context: context)
         
            managed.id = image.id
            managed.imageDescription = image.description
            managed.location = image.location
            managed.url = image.url
            
            return managed
        })
    }
    
}
