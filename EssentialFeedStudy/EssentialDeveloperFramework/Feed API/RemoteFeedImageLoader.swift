//
//  RemoteFeedImageLoader.swift
//  EssentialFeed
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public class RemoteFeedImageLoader: FeedImageLoader {
    let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let imageLoadTask = RemoteImageLoadingTask(completion: completion)
        
        let httpTask = self.client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            imageLoadTask.complete(with: result
                .mapError { _ in ImageLoadingError.connectivity }
                .flatMap { (response, data) in
                    let isValidResponse = response.isOK && !data.isEmpty
                    return isValidResponse ? .success(data) : .failure(ImageLoadingError.invalidData)
            })
        }
        imageLoadTask.wrapped = httpTask
        
        return imageLoadTask
    }
}
