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
        let loader = ImageLoaderStub(stub: .success(anyData()))
        let (_, cachingSpy) = makeSUT(loader: loader)
        
        XCTAssertEqual(cachingSpy.messages, [])
    }
    
    func test_loadImage_passesResultFromDecoratee() {
        let loader = ImageLoaderStub(stub: .success(anyData()))
        let (sut, _) = makeSUT(loader: loader)
        let data = anyData()
        
        expect(sut: sut, toLoadResult: .success(data))
    }
    
    func test_loadImage_doesNotSaveAnythingOnFailure() {
        let loader = ImageLoaderStub(stub: .failure(anyError()))
        let (sut, cachingSpy) = makeSUT(loader: loader)
        
        _ = sut.loadImage(with: anyURL(), completion: { _ in })
        
        XCTAssertEqual(cachingSpy.messages, [])
    }
    
    func makeSUT<Loader: FeedImageLoader & AnyObject>(loader: Loader) -> (FeedImageLoaderCachingDecorator, CachingSpy) {
        let cachingSpy = CachingSpy()
        let sut = FeedImageLoaderCachingDecorator(cachingSpy, decoratee: loader)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(loader)
        trackMemoryLeaks(cachingSpy)
        
        return (sut, cachingSpy)
    }
}
