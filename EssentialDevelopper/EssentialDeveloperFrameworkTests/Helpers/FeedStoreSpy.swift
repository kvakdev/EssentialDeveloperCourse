//
//  FeedStoreSpy.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/5/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialDeveloperFramework

public class FeedStoreSpy: FeedStore {
    enum Message: Equatable {
        case delete
        case insert(images: [LocalFeedImage], timestamp: Date)
    }

    var deletionCompletions: [TransactionCompletion] = []
    var insertionCompletions: [TransactionCompletion] = []
    
    var savedMessages: [Message] = []
    
    public func deleteCachedFeed(completion: @escaping TransactionCompletion) {
        savedMessages.append(.delete)
        deletionCompletions.append(completion)
    }
    
    public func insert(_ feedImages: [LocalFeedImage], timestamp: Date, completion: @escaping TransactionCompletion) {
        savedMessages.append(.insert(images: feedImages, timestamp: timestamp))
        insertionCompletions.append(completion)
    }
    
    func completeDeletionWith(_ error: Error, at index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeInsertionWith(_ error: Error, at index: Int = 0) {
        insertionCompletions[index](error)
    }
    
    func successfulyCompleteDeletion(at index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func successfulyCompleteInsertion(at index: Int = 0) {
        insertionCompletions[index](nil)
    }
}
