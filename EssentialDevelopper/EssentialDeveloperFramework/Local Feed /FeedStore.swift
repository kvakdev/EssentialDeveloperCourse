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
    typealias RetrieveCallback = (LocalFeedLoader.Result) -> Void
    
    func insert(_ items: [LocalFeedItem], timestamp: Date, completion: @escaping InsertionCallback)
    func retrieve(completion: @escaping (LocalFeedLoader.Result) -> Swift.Void)
    func deleteCache(completion: @escaping DeletionCallback)
}
