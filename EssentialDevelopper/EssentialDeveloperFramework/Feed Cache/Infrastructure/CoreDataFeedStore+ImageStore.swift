//
//  CoreDataFeedStore+FeedImageDataModel.swift
//  EssentialFeed
//
//  Created by Andre Kvashuk on 6/20/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

class CoreDataRetreiveTask: CancellableTask {
    func cancel() {
        
    }
}

enum InsertionError: Error {
    case notFound
}

extension CoreDataFeedStore: ImageStore {
    
    public func insert(image data: Data, for url: URL, completion: @escaping Closure<InsertResult>) {
        perform { context in
            completion(Result {
                try ManagedFeedImage.first(with: url)
                    .map { $0.data = data }
                    .map(context.save)
            })
        }
    }
    
    @discardableResult
    public func retrieveImageData(from url: URL, completion: @escaping (ImageStore.RetrieveResult) -> Void) -> CancellableTask {
        
        perform { context in
            completion(
            Result {
                try ManagedFeedImage.first(with: url)?.data
            })
        }
        
        return CoreDataRetreiveTask()
    }
}
