//
//  FeedImageCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/25/22.
//

import XCTest
import EssentialFeed

class CachingSpy {
    var messages: [AnyHashable] = []
}

class FeedImageLoaderCachingDecorator: FeedImageLoader {
    let decoratee: FeedImageLoader
    let cache: CachingSpy
    
    init(_ cache: CachingSpy, decoratee: FeedImageLoader) {
        self.cache = cache
        self.decoratee = decoratee
    }
    
    func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        return decoratee.loadImage(with: url, completion: completion)
    }
}

class FeedImageCacheDecoratorTests: XCTestCase, FeedImageLoaderTestCase {
    
    func test_init_works() {
        let cachingSpy = CachingSpy()
        let loader = ImageLoaderStub(stub: .success(anyData()))
        _ = FeedImageLoaderCachingDecorator(cachingSpy, decoratee: loader)
        
        XCTAssertEqual(cachingSpy.messages, [])
    }
    
    func test_loadImage_passesResultFromDecoratee() {
        let cachingSpy = CachingSpy()
        let loader = ImageLoaderStub(stub: .success(anyData()))
        let sut = FeedImageLoaderCachingDecorator(cachingSpy, decoratee: loader)
        let data = anyData()
        
        expect(sut: sut, toLoadResult: .success(data))
    }
}
