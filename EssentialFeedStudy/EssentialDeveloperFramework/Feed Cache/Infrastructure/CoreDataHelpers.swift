//
//  CoreDataHelpers.swift
//  EssentialFeed
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import CoreData


public extension NSPersistentContainer {
   
    static func load(with modelName: String, model: NSManagedObjectModel, storeURL: URL) throws -> NSPersistentContainer {
        
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.persistentStoreDescriptions = [storeDescription]
        
        var loadError: Error?
        
        container.loadPersistentStores { _, error in
            loadError = error
        }
        
        try loadError.map { throw $0 }
        
        return container
    }
}

extension NSManagedObjectModel {
    static func load(with modelName: String, in bundle: Bundle) -> NSManagedObjectModel? {
        bundle
            .url(forResource: modelName, withExtension: "momd")
            .flatMap { NSManagedObjectModel(contentsOf: $0) }
    }
}
