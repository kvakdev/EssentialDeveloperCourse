//
//  FeedStore.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 6/5/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public protocol FeedStore {
    typealias TransactionCompletion = (Error?) -> Void
    
    func deleteCachedFeed(completion: @escaping TransactionCompletion)
    func insert(_ feed: [FeedImage], timestamp: Date, completion: @escaping TransactionCompletion)
}
