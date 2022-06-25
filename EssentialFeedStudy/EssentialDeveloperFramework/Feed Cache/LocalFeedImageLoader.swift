//
//  LocalFeedImageLoader.swift
//  EssentialFeed
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public protocol CancellableTask {
    func cancel()
}

public protocol ImageStore {
    typealias RetrieveResult = Swift.Result<Data?, Error>  
    typealias InsertResult = Swift.Result<Void, Error>
    
    @discardableResult
    func retrieveImageData(from url: URL, completion: @escaping (RetrieveResult) -> Void) -> CancellableTask
    func insert(image data: Data, for url: URL, completion: @escaping Closure<InsertResult>)
}

public enum LoadError: Error {
    case failed
    case notFound
}

public class LocalFeedImageLoader: FeedImageLoader, ImageCache {
    let store: ImageStore
    
    public init(store: ImageStore) {
        self.store = store
    }
    
    public func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        let task = LocalImageLoaderTask(completion: completion)
        
        let retreiveTask = store.retrieveImageData(from: url) { [weak self] result in
            guard self != nil else { return }
            
            task.complete(with: result
                .mapError { _ in LoadError.failed }
                .flatMap { data in
                    data.map { .success($0) } ?? .failure(LoadError.notFound)
                }
            )
        }
        
        task.wrapped = retreiveTask
        
        return task
    }
    
    public func save(image data: Data, for url: URL, completion: @escaping Closure<ImageCache.Result>) {
        store.insert(image: data, for: url) { [weak self] result in
            guard self != nil else { return }
            
            completion(result.mapError { _ in LoadError.failed })
        }
    }
}
