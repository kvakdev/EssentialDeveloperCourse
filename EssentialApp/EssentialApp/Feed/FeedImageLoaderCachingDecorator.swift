//
//  FeedImageLoaderCachingDecorator.swift
//  EssentialApp
//
//  Created by Andre Kvashuk on 6/25/22.
//

import Foundation
import EssentialFeed

public class FeedImageLoaderCachingDecorator: FeedImageLoader {
    let decoratee: FeedImageLoader
    let cache: ImageCache
    
    public init(_ cache: ImageCache, decoratee: FeedImageLoader) {
        self.cache = cache
        self.decoratee = decoratee
    }
    
    public func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        return decoratee.loadImage(with: url) { [weak self] result in
            completion(result.map { data in
                self?.saveIgnoringResult(data: data, url: url)
                
                return data
            })
        }
    }
    
    private func saveIgnoringResult(data: Data, url: URL) {
        self.cache.save(image: data, for: url, completion: { _ in })
    }
}
