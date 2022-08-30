//
//  FeedLoaderComposit.swift
//  EssentialApp
//
//  Created by Andre Kvashuk on 6/23/22.
//

import Foundation
import EssentialFeed

public class FeedLoaderWithFallbackComposit: FeedLoader {
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> ()) {
        primary.load() { [weak self] primaryResult in
            switch primaryResult {
            case .success(let success):
                completion(.success(success))
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
