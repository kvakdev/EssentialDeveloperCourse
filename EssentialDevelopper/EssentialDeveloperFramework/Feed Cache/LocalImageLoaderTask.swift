//
//  LocalImageLoaderTask.swift
//  EssentialFeed
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

class LocalImageLoaderTask: FeedImageDataLoaderTask {
    private var completion: Closure<FeedImageLoader.Result>?
    
    var wrapped: CancellableTask?
    
    init(completion: @escaping (FeedImageLoader.Result) -> Void) {
        self.completion = completion
    }
    
    func complete(with result: FeedImageLoader.Result) {
        self.completion?(result)
    }
    
    func cancel() {
        completion = nil
        wrapped?.cancel()
    }
}
