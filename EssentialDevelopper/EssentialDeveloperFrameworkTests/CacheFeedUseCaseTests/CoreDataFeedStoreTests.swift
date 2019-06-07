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

class CoreDataFeedStore {
    let url: URL
    let container: NSPersistentContainer
    let context: NSManagedObjectContext
    
    init(url: URL, bundle: Bundle = .main) throws {
        self.url = url
        
        container = try NSPersistentContainer.load(url: url, name: "FeedStore", bundle: bundle)
        context = container.newBackgroundContext()
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.InsertionCallback) {}
    
    func retrieve(completion: @escaping (FeedRetrieveResult) -> Swift.Void) {
        completion(.empty)
    }
}

class CoreDataFeedStoreTests: XCTestCase {
    
    func test_init_doesNotFail() {
        let sut = makeSUT()
        
        XCTAssertNotNil(sut)
    }
    
    func test_retrieve_onEmptyCacheReturnsEmptyArray() {
        let sut = makeSUT()
        let exp = expectation(description: "waiting for retrieve")
        
        sut.retrieve { result in
            switch result {
            case .empty:
                break
            default:
                XCTFail("unexpected non empty result")
            }
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1.0)
    }
    
    func makeSUT() -> CoreDataFeedStore {
        let bundle = Bundle(for: CoreDataFeedStore.self)
        let url = URL(fileURLWithPath: "/dev/null")
        let sut = try! CoreDataFeedStore(url: url, bundle: bundle)
        
        trackMemoryLeaks(sut)
        
        return sut
    }
}

