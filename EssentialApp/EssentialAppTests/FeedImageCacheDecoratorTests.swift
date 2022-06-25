//
//  FeedImageCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/25/22.
//

import XCTest
import EssentialFeed
import EssentialApp


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
    
    func test_loadImage_savesImageOnSuccessfulLoadWithDelay() {
        let data = Data("some data".utf8)
        let url = anyURL()
        let loader = ImageLoaderStub(stub: .success(data), autoComplete: false)
        let (sut, cachingSpy) = makeSUT(loader: loader)
        let exp = expectation(description: "wait for load to complete")
        
        _ = sut.loadImage(with: url, completion: { _ in
            exp.fulfill()
        })
        loader.complete()
        wait(for: [exp], timeout: 1.0)
        XCTAssertEqual(cachingSpy.messages, [.save(data, url)])
    }
}

private extension FeedImageCacheDecoratorTests {
    func makeSUT<Loader: FeedImageLoader & AnyObject>(loader: Loader, file: StaticString = #file, line: UInt = #line) -> (FeedImageLoaderCachingDecorator, CachingSpy) {
        let cachingSpy = CachingSpy()
        let sut = FeedImageLoaderCachingDecorator(loader, cache: cachingSpy)
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(loader, file: file, line: line)
        trackMemoryLeaks(cachingSpy, file: file, line: line)
        
        return (sut, cachingSpy)
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
}
