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

extension CoreDataFeedStore: ImageStore {
    
    public func insert(image data: Data, for url: URL, completion: @escaping Closure<InsertResult>) {
        completion(.success(()))
    }
    
    @discardableResult
    public func retrieveImageData(from url: URL, completion: @escaping (ImageStore.RetrieveResult) -> Void) -> CancellableTask {
        
        completion(.success(.none))
        
        return CoreDataRetreiveTask()
    }
}
