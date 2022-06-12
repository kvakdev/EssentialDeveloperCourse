//
//  LoaderSpy.swift
//  EssentialFeed_iOSTests
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed_iOS
import EssentialFeed

class LoaderSpy: FeedLoader, FeedImageLoader {
    var completions = [(FeedLoader.Result) -> ()]()
    var imageLoadCompletions = [(url: URL, completion: (ImageLoadResult) -> ())]()
    var loadedURLs: [URL] {
        imageLoadCompletions.map { $0.url }
    }
    var cancelledUrls: [URL] = []
    
    var loadCount: Int {
        completions.count
    }
    
    private class FeedImageLoaderTaskSpy: FeedImageDataLoaderTask {
        let completion: () -> Void
        
        init(cancelCompletion: @escaping () -> Void) {
            self.completion = cancelCompletion
        }
        
        func cancel() {
            completion()
        }
    }
    
    func load(completion: @escaping (FeedLoader.Result) -> ()) {
        completions.append(completion)
    }
    
    func complete(with feed: [FeedImage] = [], index: Int = 0) {
        completions[index](.success(feed))
    }
    
    func completeWithError(index: Int = 0) {
        completions[index](.failure(NSError(domain: "Loader spy error", code: 0)))
    }
    
    func loadImage(with url: URL, completion: @escaping (ImageLoadResult) -> Void) -> FeedImageDataLoaderTask {
        imageLoadCompletions.append((url: url, completion: completion))
        
        return FeedImageLoaderTaskSpy(cancelCompletion: { [weak self] in self?.cancelImageLoad(with: url) })
    }
    
    func cancelImageLoad(with url: URL) {
        cancelledUrls.append(url)
    }
    
    func completeImageLoadWithSuccess(_ data: Data = Data(), index: Int = 0) {
        imageLoadCompletions[index].completion(.success(data))
    }
    
    func completeImageLoadWithFailure(index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        imageLoadCompletions[index].completion(.failure(error))
    }
}
