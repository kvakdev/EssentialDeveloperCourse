//
//  RemoteImageLoadingTask.swift
//  EssentialFeed
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public class RemoteImageLoadingTask: CancellableTask {
    var wrapped: HTTPClientTask?
    var completion: Closure<FeedImageLoader.Result>?
    
    init(completion: @escaping Closure<FeedImageLoader.Result>) {
        self.completion = completion
    }
    
    func complete(with result: FeedImageLoader.Result) {
        completion?(result)
    }
    
    public func cancel() {
        completion = nil
        wrapped?.cancel()
    }
}
