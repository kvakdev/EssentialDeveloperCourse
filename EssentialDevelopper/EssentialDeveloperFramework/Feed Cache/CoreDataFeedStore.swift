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
    
    private let container: NSPersistentContainer
    private let backgroundContext: NSManagedObjectContext
    
    public init(bundle: Bundle = .main, storeURL: URL) throws {
        try self.container = NSPersistentContainer.load(with: "FeedStore", in: bundle, storeURL: storeURL)
       
        backgroundContext = self.container.newBackgroundContext()
    }
    
    public func deleteCachedFeed(completion: @escaping TransactionCompletion) {
        
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping TransactionCompletion) {
        
    }
    
    public func retrieve(_ completion: @escaping RetrieveCompletion) {
        completion(.empty)
    }
}

enum LoadingError: Swift.Error {
    case modelNotFound
    case failedToLoadPersistentStores(Swift.Error)
}


extension NSPersistentContainer {
    static func load(with modelName: String, in bundle: Bundle, storeURL: URL) throws -> NSPersistentContainer {
        
        guard let model = NSManagedObjectModel.load(with: modelName, in: bundle) else {
            throw LoadingError.modelNotFound
        }
        
        let storeDescription = NSPersistentStoreDescription(url: storeURL)
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        container.persistentStoreDescriptions = [storeDescription]
        
        var loadError: Error?
        
        container.loadPersistentStores { _, error in
            loadError = error
        }
        
        try loadError.map { throw LoadingError.failedToLoadPersistentStores($0) }
        
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


private class ManagedFeedCache: NSManagedObject {
    @NSManaged var timestamp: Date
    @NSManaged var feed: NSOrderedSet
}

private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedFeedCache
}
