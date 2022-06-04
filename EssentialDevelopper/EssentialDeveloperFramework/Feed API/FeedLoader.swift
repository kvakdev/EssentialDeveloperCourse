//
//  FeedLoader.swift
//  EssentialDevelopper
//
//  Created by Andre Kvashuk on 4/16/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public enum FeedLoaderResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoaderProtocol {
    func load(completion: @escaping (FeedLoaderResult) -> ())
}
