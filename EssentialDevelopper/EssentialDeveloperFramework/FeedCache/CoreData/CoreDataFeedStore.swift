//
//  CoreDataFeedStore.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 6/7/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import CoreData

public class CoreDataFeedStore {
    let url: URL
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    public init(url: URL, bundle: Bundle = .main) throws {
        self.url = url
        
        container = try NSPersistentContainer.load(url: url, name: "FeedStore", bundle: bundle)
        context = container.newBackgroundContext()
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCallback) {
        
        
        
    }
    
    public func retrieve(completion: @escaping (FeedRetrieveResult) -> Swift.Void) {
        completion(.empty)
    }
}
