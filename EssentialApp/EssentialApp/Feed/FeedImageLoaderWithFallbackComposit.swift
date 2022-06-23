//
//  FeedImageLoaderWithFallbackComposit.swift
//  EssentialApp
//
//  Created by Andre Kvashuk on 6/23/22.
//

import Foundation
import EssentialFeed

private class TaskWrapper: FeedImageDataLoaderTask {
    var wrapped: FeedImageDataLoaderTask?
    var completion: Closure<FeedImageLoader.Result>?
    
    func complete(_ result: FeedImageLoader.Result) {
        completion?(result)
    }
    
    func cancel() {
        wrapped?.cancel()
        completion = nil
    }
}

public class ImageLoaderWithFallbackComposit: FeedImageLoader {
    private let primaryLoader: FeedImageLoader
    private let fallbackLoader: FeedImageLoader
    
    public init(primaryLoader: FeedImageLoader, fallbackLoader: FeedImageLoader) {
        self.primaryLoader = primaryLoader
        self.fallbackLoader = fallbackLoader
    }
    
    public func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let wrapper = TaskWrapper()
        wrapper.completion = completion
        
        let primaryTask = primaryLoader.loadImage(with: url) { [weak self] result in
            switch result {
            case .success(let data):
                wrapper.complete(.success(data))
            case .failure:
                let fallbackTask = self?.fallbackLoader.loadImage(with: url) { result in
                    wrapper.complete(result)
                }
                wrapper.wrapped = fallbackTask
            }
        }
        
        wrapper.wrapped = primaryTask
        
        return wrapper
    }
}
