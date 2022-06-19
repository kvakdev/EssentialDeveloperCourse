//
//  LocalFeedImageLoader.swift
//  EssentialFeed
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public enum ImageRetreivalError: Error {
    case noImage
}

public protocol CancellableTask {
    func cancel()
}

public protocol ImageStore {
    typealias Result = Swift.Result<Data?, Error>
    typealias InsertResult = Swift.Result<Void, Error>
    
    func retreiveImageData(from url: URL, completion: @escaping (Result) -> Void) -> CancellableTask
    func insert(image data: Data, for url: URL, completion: @escaping Closure<InsertResult>)
}

public class LocalFeedImageLoader: FeedImageLoader {
    let store: ImageStore
    
    public init(store: ImageStore) {
        self.store = store
    }
    
    public func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = LocalImageLoaderTask(completion: completion)
        
        let retreiveTask = store.retreiveImageData(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .failure(let error):
                task.complete(with: .failure(error))
            case .success(let data):
                guard let data = data else {
                    return task.complete(with: .failure(ImageRetreivalError.noImage))
                }
                task.complete(with: .success(data))
            }
        }
        
        task.wrapped = retreiveTask
        
        return task
    }
    
    public func save(image data: Data, for url: URL, completion: @escaping Closure<Result<Void, Error>>) {
        store.insert(image: data, for: url, completion: completion)
    }
}
