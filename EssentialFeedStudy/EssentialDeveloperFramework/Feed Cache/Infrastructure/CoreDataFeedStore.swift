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
    
    enum StoreError: Swift.Error {
        case modelNotFound
        case failedToLoadPersistentStores(Swift.Error)
    }
    
    private let container: NSPersistentContainer
    private let context: NSManagedObjectContext
    private static let modelName = "FeedStore"
    private static let model = NSManagedObjectModel.load(with: modelName, in: Bundle(for: CoreDataFeedStore.self))
    
    public init(storeURL: URL) throws {
        guard let model = CoreDataFeedStore.model else {
            throw StoreError.modelNotFound
        }
        
        do {
            try self.container = NSPersistentContainer.load(with: CoreDataFeedStore.modelName, model: model, storeURL: storeURL)
            
            context = self.container.newBackgroundContext()
        } catch let error {
            
            throw StoreError.failedToLoadPersistentStores(error)
        }
    }
    
    func perform(_ action: @escaping (NSManagedObjectContext) -> Void) {
        let context = self.context
        context.perform { action(context) }
    }
    
    func cleanUpStoreReferences() {
         context.performAndWait {
            let coordinator = self.container.persistentStoreCoordinator
            try? coordinator.persistentStores.forEach(coordinator.remove)
        }
    }
    
    deinit {
        cleanUpStoreReferences()
    }
}
