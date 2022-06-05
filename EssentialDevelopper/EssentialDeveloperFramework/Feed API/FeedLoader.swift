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

extension FeedLoaderResult: Equatable {
    public static func == (lhs: FeedLoaderResult, rhs: FeedLoaderResult) -> Bool {
        switch (lhs, rhs) {
        case (.success(let leftFeed), .success(let rightFeed)):
                return leftFeed == rightFeed
        case (.failure(let leftError), .failure(let rightError)):
                return (leftError as? NSError) == (rightError as? NSError)
        default:
                return false
        }
    }
}
