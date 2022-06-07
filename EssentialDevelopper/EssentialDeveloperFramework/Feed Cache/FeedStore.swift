//
//  FeedStore.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 6/5/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public enum RetrieveResult {
    case success(feed: [LocalFeedImage], timestamp: Date)
    case empty
    case failure(Error)
}

public protocol FeedStore {
    typealias TransactionCompletion = (Error?) -> Void
    typealias RetrieveCompletion = (RetrieveResult) -> Void
    
    func deleteCachedFeed(completion: @escaping TransactionCompletion)
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping TransactionCompletion)
    func retrieve(_ completion: @escaping RetrieveCompletion)
}

public struct LocalFeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let url: URL
    
    public init(id: UUID, description: String? = nil, location: String? = nil, url: URL) {
        self.id = id
        self.description = description
        self.url = url
        self.location = location
    }
}
