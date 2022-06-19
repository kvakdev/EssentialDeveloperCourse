//
//  MainThreadDispatchDecorator.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/16/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed

class MainThreadDispatchDecorator<T> {
    private let decoratee: T
    
    init(decoratee: T) {
        self.decoratee = decoratee
    }
    
    func dispatch(_ completion: @escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async { completion() }
            return
        }
        
        completion()
    }
}

extension MainThreadDispatchDecorator: FeedLoader where T == FeedLoader {
    func load(completion: @escaping (Result<[FeedImage], Error>) -> ()) {
        decoratee.load { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}

extension MainThreadDispatchDecorator: FeedImageLoader where T == FeedImageLoader {
    func loadImage(with url: URL, completion: @escaping (ImageLoadResult) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImage(with: url) { [weak self] result in
            self?.dispatch { completion(result) }
        }
    }
}
