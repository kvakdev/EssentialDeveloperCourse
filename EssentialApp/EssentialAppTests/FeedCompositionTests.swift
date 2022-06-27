//
//  FeedCompositionTests.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/25/22.
//

import XCTest
import EssentialFeed
import EssentialFeed_iOS
@testable import EssentialApp

class FeedCompositionTests: XCTestCase {
    func test_app_displaysFeedViewController() {
        XCTAssertNoThrow(try launch())
    }
    
    func test_app_rendersCells() throws {
        let (sut, _) = try launch(store: .empty, client: .online)
        
        XCTAssertEqual(sut.numberOfRenderedImageViews, 2)
    }
    
    func test_appInOfflineMode_rendersCachesFeed() throws {
        let (offlineSUT, _) = try launch(store: InMemoryStore.validCache, client: .offline)
        
        XCTAssertEqual(offlineSUT.numberOfRenderedImageViews, 1)
    }
    
    func test_appInOfflineModeWithNoCache_rendersEmptyFeed() throws {
        let (offlineSUT, _) = try launch(store: InMemoryStore.empty, client: .offline)
        
        XCTAssertEqual(offlineSUT.numberOfRenderedImageViews, 0)
    }
    
    func test_app_validatesCacheOnGoingToBackground() throws {
        let store = InMemoryStore.invalidCache
        let (_, sut) = try launch(store: store, client: .offline)
        
        sut.sceneWillResignActive(UIApplication.shared.connectedScenes.first!)
        
        XCTAssertNil(store.feed, "Expected invalid cache to be deleted on going to background")
    }
    
    func launch(store: InMemoryStore = .empty, client: DebugHTTPClient = DebugHTTPClient.online) throws -> (FeedViewController, SceneDelegate) {
        let sceneDelegate = SceneDelegate(feedStore: store, client: client)
        sceneDelegate.window = UIWindow()
        sceneDelegate.setup()
        
        guard
            let navController = sceneDelegate.window?.rootViewController as? UINavigationController,
            let vc = navController.viewControllers[0] as? FeedViewController else {
            
            throw NSError(domain: "No Navigation Controller", code: 0)
        }
        
        return (vc, sceneDelegate)
    }
    
}

class InMemoryStore: FeedStore {
    var feed: ([LocalFeedImage], Date)?
    var images: [URL: Data] = [:]
    
    init(images: [LocalFeedImage], date: Date) {
        self.feed = (images, date)
    }
    
    func deleteCachedFeed(completion: @escaping TransactionCompletion) {
        feed = nil
        completion(.success(()))
    }
    
    func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping TransactionCompletion) {
        self.feed = (feed, timestamp)
        completion(.success(()))
    }
    
    func retrieve(_ completion: @escaping RetrieveCompletion) {
        completion(.success(feed))
    }
    
    static var empty: InMemoryStore {
        InMemoryStore(images: [], date: Date())
    }
    
    static var invalidCache: InMemoryStore {
        InMemoryStore(images: [LocalFeedImage(id: UUID(), url: anyURL())], date: Date.distantPast)
    }
    
    static var validCache: InMemoryStore {
        InMemoryStore(images: [LocalFeedImage(id: UUID(), url: anyURL())], date: Date())
    }
}

extension InMemoryStore: ImageStore {
  
    func retrieveImageData(from url: URL, completion: @escaping (Result<Data?, Swift.Error>) -> Void) -> CancellableTask {
        completion(.success(images[url]))
        
        return AnyCancellableTask()
    }
    
    public func insert(image data: Data, for url: URL, completion: @escaping Closure<Result<Void, Error>>) {
        completion(.success(()))
    }
}


class DebugHTTPClient: HTTPClient {
    static var online: DebugHTTPClient {
        DebugHTTPClient(connectivity: true)
    }
    static var offline: DebugHTTPClient {
        DebugHTTPClient(connectivity: false)
    }
    
    private let connectivity: Bool
    
    init(connectivity: Bool) {
        self.connectivity = connectivity
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        if !connectivity {
            completion(.failure(NSError(domain: "OFFLINE", code: 0)))
        } else {
            completion(.success((makeResponse(url: url), makeData(url: url))))
        }
        return AnyTask()
    }
                       
    private func makeResponse(url: URL) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func makeData(url: URL) -> Data {
        if url.absoluteString == debugImageURL() {
            return makeImageData()
        } else {
            return debugFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        let size = CGSize(width: 1, height: 1)
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.red.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!.pngData()!
    }
    
    private func debugFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items" : [
            ["id": UUID().uuidString, "image": "\(debugImageURL()))"],
            ["id": UUID().uuidString, "image": "\(debugImageURL()))"]
                    ]])
    }
    
    private func debugImageURL() -> String {
        "http://image.com"
    }
    
    private class AnyTask: HTTPClientTask {
        func cancel() {}
    }
}
