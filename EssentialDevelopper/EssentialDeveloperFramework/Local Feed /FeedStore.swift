//
//  FeedStore.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 4/26/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public protocol FeedStore {
    typealias DeletionCallback = (Error?) -> Void
    typealias InsertionCallback = (Error?) -> Void
    typealias RetrieveCallback = (LocalFeedLoader.LoadFeedResult) -> Void
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCallback)
    func retrieve(completion: @escaping (LocalFeedLoader.LoadFeedResult) -> Swift.Void)
    func deleteCache(completion: @escaping DeletionCallback)
}
