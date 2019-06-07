//
//  CoreDataHelpers.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 6/7/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import CoreData

internal extension NSManagedObjectModel {
    static func with(name: String, bundle: Bundle) throws -> NSManagedObjectModel? {
        if let url = bundle.url(forResource: name, withExtension: "momd") {
            return NSManagedObjectModel(contentsOf: url)
        }
        
        return nil
    }
}

internal extension NSPersistentContainer {
    internal enum CoreDataError: Error {
        case noManagedDataModel
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    internal static func load(url: URL, name: String, bundle: Bundle) throws -> NSPersistentContainer {
        guard let model = try NSManagedObjectModel.with(name: name, bundle: bundle) else {
            throw CoreDataError.noManagedDataModel
        }
        
        let description = NSPersistentStoreDescription(url: url)
        
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        
        container.persistentStoreDescriptions = [description]
        
        var error: Swift.Error?
        
        container.loadPersistentStores { error = $1 }
        
        try error.map { throw CoreDataError.failedToLoadPersistentStores($0) }
        
        return container
    }
}
