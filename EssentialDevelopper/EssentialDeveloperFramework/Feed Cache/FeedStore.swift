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
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping TransactionCompletion)
}

public struct LocalFeedImage: Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) {
        self.id = id
        self.description = description
        self.imageURL = imageUrl
        self.location = location
    }
}
