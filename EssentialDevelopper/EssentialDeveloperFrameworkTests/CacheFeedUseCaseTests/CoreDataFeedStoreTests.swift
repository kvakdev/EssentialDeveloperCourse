//
//  CoreDataFeedStoreTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/6/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialDeveloperFramework
import CoreData

extension NSManagedObjectModel {
    static func with(name: String, bundle: Bundle) throws -> NSManagedObjectModel {
        guard let path = bundle.path(forResource: name, ofType: "momd") else {
            throw anyNSError()
        }
        
        let url = URL(fileURLWithPath: path)
        
        return NSManagedObjectModel(contentsOf: url)!
    }
}

extension NSPersistentContainer {
    internal static func load(url: URL, name: String, bundle: Bundle) throws -> NSPersistentContainer {
        let model = try NSManagedObjectModel.with(name: name, bundle: bundle)
        let description = NSPersistentStoreDescription(url: url)
        
        let container = NSPersistentContainer(name: name, managedObjectModel: model)
        container.persistentStoreDescriptions = [description]
        
        return container
    }
}

class CoreDataFeedStore {
    let url: URL
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init(url: URL, bundle: Bundle = .main) throws {
        self.url = url
        
        container = try NSPersistentContainer.load(url: url, name: "FeedStore", bundle: bundle)
        context = container.newBackgroundContext()
    }
}

class CoreDataFeedStoreTests: XCTestCase {
    
    func test_init_doesNotFail() {
        let sut = makeSUT()
        
        XCTAssertNotNil(sut)
    }
    
    func makeSUT() -> CoreDataFeedStore {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let url = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(url: url, bundle: bundle)
        
        trackMemoryLeaks(sut)
        
        return sut
    }
}
