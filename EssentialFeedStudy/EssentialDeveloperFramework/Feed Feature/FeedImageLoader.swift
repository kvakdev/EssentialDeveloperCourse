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
    typealias Result = Swift.Result<Data, Error>
    
    func loadImage(with url: URL, completion: @escaping (Result) -> Void) -> FeedImageDataLoaderTask
}

public protocol ImageCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(image data: Data, for url: URL, completion: @escaping Closure<Result>)
}
