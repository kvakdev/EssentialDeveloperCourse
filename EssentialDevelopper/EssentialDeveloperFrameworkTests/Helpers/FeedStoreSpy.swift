//
//  FeedStoreSpy.swift
//  EssentialFeedTests
//
//  Created by Andre Kvashuk on 6/5/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed

public class FeedStoreSpy: FeedStore {
    enum Message: Equatable {
        case delete
        case insert(images: [LocalFeedImage], timestamp: Date)
        case retrieve
    }

    var deletionCompletions: [TransactionCompletion] = []
    var insertionCompletions: [TransactionCompletion] = []
    var retrieveCompletions: [RetrieveCompletion] = []
    
    var savedMessages: [Message] = []
    
    public func deleteCachedFeed(completion: @escaping TransactionCompletion) {
        savedMessages.append(.delete)
        deletionCompletions.append(completion)
    }
    
    public func insert(_ feedImages: [LocalFeedImage], timestamp: Date, completion: @escaping TransactionCompletion) {
        savedMessages.append(.insert(images: feedImages, timestamp: timestamp))
        insertionCompletions.append(completion)
    }
    
    public func retrieve(_ completion: @escaping RetrieveCompletion) {
        retrieveCompletions.append(completion)
        savedMessages.append(.retrieve)
    }
    
    func completeDeletionWith(_ error: Error, at index: Int = 0) {
        deletionCompletions[index](.failure(error))
    }
    
    func completeInsertionWith(_ error: Error, at index: Int = 0) {
        insertionCompletions[index](.failure(error))
    }
    
    func completeRetrieveWith(_ error: Error, at index: Int = 0) {
        retrieveCompletions[index](.failure(error))
    }
    
    func completeRetrieveWith(_ feed: [LocalFeedImage], timestamp: Date, at index: Int = 0) {
        retrieveCompletions[index](.success((feed: feed, timestamp: timestamp)))
    }
    
    func successfulyCompleteDeletion(at index: Int = 0) {
        deletionCompletions[index](.success(()))
    }
    
    func successfulyCompleteInsertion(at index: Int = 0) {
        insertionCompletions[index](.success(()))
    }
}
