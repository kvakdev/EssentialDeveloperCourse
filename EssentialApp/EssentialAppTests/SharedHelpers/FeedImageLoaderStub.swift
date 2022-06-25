//
//  FeedImageLoaderStub.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/25/22.
//

import Foundation
import EssentialFeed

class ImageLoaderStub: FeedImageLoader {
    private let stub: FeedImageLoader.Result
    private var completion: ((FeedImageLoader.Result) -> Void)?
    private let autoComplete: Bool
    
    init(stub: FeedImageLoader.Result, autoComplete: Bool = true) {
        self.stub = stub
        self.autoComplete = autoComplete
    }
    
    func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> CancellableTask {
        let task = AnyCancellableTask()
        
        if autoComplete {
            completion(stub)
        } else {
            self.completion = completion
        }
        
        return task
    }
    
    func complete() {
        self.completion?(stub)
    }
}
