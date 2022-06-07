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
        
        let context = backgroundContext
        
        context.perform {
            do {
                let cache = try ManagedFeedCache.newUniqueInstance(in: context)
                cache.timestamp = timestamp
                cache.feed = ManagedFeedImage.images(from: feed, in: context)
                
                try context.save()
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func retrieve(_ completion: @escaping RetrieveCompletion) {
        let context = self.backgroundContext
        
        context.perform {
            do {
                if let cache = try ManagedFeedCache.find(in: context) {
                    completion(.success(feed: cache.localFeed,
                                        timestamp: cache.timestamp))
                } else {
                    completion(.empty)
                }
            } catch {
                completion(.failure(error))
            }
        }
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


@objc(ManagedFeedCache)
private class ManagedFeedCache: NSManagedObject {
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

@objc(ManagedFeedImage)
private class ManagedFeedImage: NSManagedObject {
    @NSManaged var id: UUID
    @NSManaged var imageDescription: String?
    @NSManaged var location: String?
    @NSManaged var url: URL
    @NSManaged var cache: ManagedFeedCache
    
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
}
