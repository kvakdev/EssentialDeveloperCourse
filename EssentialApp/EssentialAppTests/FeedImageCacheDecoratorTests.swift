//
//  FeedImageCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/25/22.
//

import XCTest

class CachingSpy {
    var messages: [AnyHashable] = []
}

class FeedImageLoaderCachingDecorator {
    let cache: CachingSpy
    
    init(_ cache: CachingSpy) {
        self.cache = cache
    }
}

class FeedImageCacheDecoratorTests: XCTestCase {
    
    func test_init_works() {
        let cachingSpy = CachingSpy()
        _ = FeedImageLoaderCachingDecorator(cachingSpy)
        
        XCTAssertEqual(cachingSpy.messages, [])
    }
    
}
