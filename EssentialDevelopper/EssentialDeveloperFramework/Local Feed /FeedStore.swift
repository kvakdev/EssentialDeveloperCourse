//
//  FeedStore.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 4/26/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public enum FeedRetrieveResult {
    case empty
    case failure(Error)
    case found(feed: [LocalFeedImage], timestamp: Date)
}

public protocol FeedStore {
    typealias DeletionCallback = (Error?) -> Void
    typealias InsertionCallback = (Error?) -> Void
    typealias RetrieveCallback = (FeedRetrieveResult) -> Void
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCallback)
    func retrieve(completion: @escaping (FeedRetrieveResult) -> Swift.Void)
    func deleteCache(completion: @escaping DeletionCallback)
}
