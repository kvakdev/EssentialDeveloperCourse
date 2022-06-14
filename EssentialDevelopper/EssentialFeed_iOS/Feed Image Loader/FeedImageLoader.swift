//
//  FeedImageLoader.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageLoader {
    typealias ImageLoadResult = Result<Data, Error>
    
    func loadImage(with url: URL, completion: @escaping (ImageLoadResult) -> Void) -> FeedImageDataLoaderTask
}
