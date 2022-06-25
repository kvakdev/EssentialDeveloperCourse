//
//  FeedImageCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/25/22.
//

import XCTest
import EssentialFeed

protocol ImageCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(image data: Data, for url: URL, completion: @escaping Closure<Result>)
}

class CachingSpy: ImageCache {
    enum Message: Equatable {
        case save(Data, URL)
    }
    var messages: [Message] = []
    
    public func save(image data: Data, for url: URL, completion: @escaping Closure<ImageCache.Result>) {
        self.messages.append(.save(data, url))
    }
}

class FeedImageLoaderCachingDecorator: FeedImageLoader {
    let decoratee: FeedImageLoader
    let cache: ImageCache
    
    init(_ cache: ImageCache, decoratee: FeedImageLoader) {
        self.cache = cache
        self.decoratee = decoratee
    }
    
    func loadImage(with url: URL, completion: @escaping (FeedImageLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        
        return decoratee.loadImage(with: url) { result in
            completion(result.map { data in
                self.saveIgnoringResult(data: data, url: url)
                
                return data
            })
        }
    }
    
    private func saveIgnoringResult(data: Data, url: URL) {
        self.cache.save(image: data, for: url, completion: { _ in })
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
    
    func test_loadImage_savesImageOnSuccessfulLoad() {
        let data = Data("some data".utf8)
        let url = anyURL()
        let loader = ImageLoaderStub(stub: .success(data))
        let (sut, cachingSpy) = makeSUT(loader: loader)
        
        _ = sut.loadImage(with: url, completion: { _ in })
        
        XCTAssertEqual(cachingSpy.messages, [.save(data, url)])
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
