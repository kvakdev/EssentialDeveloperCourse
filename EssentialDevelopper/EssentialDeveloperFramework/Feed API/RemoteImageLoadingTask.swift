//
//  RemoteImageLoadingTask.swift
//  EssentialFeed
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public class RemoteImageLoadingTask: FeedImageDataLoaderTask {
    var wrapped: HTTPClientTask?
    var completion: Closure<FeedImageLoader.ImageLoadResult>?
    
    init(completion: @escaping Closure<FeedImageLoader.ImageLoadResult>) {
        self.completion = completion
    }
    
    func complete(with result: FeedImageLoader.ImageLoadResult) {
        completion?(result)
    }
    
    public func cancel() {
        completion = nil
        wrapped?.cancel()
    }
}
