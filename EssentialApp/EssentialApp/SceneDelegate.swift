//
//  SceneDelegate.swift
//  EssentialApp
//
//  Created by Andre Kvashuk on 6/25/22.
//

import Foundation
import UIKit
import EssentialFeed
import CoreData
import EssentialFeed_iOS

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = scene as? UIWindowScene else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let storeURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Feed-store.sqlite")
               let feedStore = try! CoreDataFeedStore(storeURL: storeURL)
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        let value = UserDefaults.standard.string(forKey: "connectivity")
        let isOffline = value == "offline"
        let client = makeHTTPClient(isOffline: isOffline)
        
        let remoteImageLoader = RemoteFeedImageLoader(client: client)
                let localImageLoader = LocalFeedImageLoader(store: feedStore)
                let remoteCachingFeedImageLoader = FeedImageLoaderCachingDecorator(remoteImageLoader, cache: localImageLoader)
                
                let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
                let localFeedLoader = LocalFeedLoader(feedStore) { Date() }
                let cachingRemoteFeedLoader = FeedCacheDecorator(decoratee: remoteFeedLoader, cache: localFeedLoader)
                
                let combinedFeedLoader = FeedLoaderWithFallbackComposit(
                    primary: cachingRemoteFeedLoader,
                    fallback: localFeedLoader
                )
                let imageLoader = ImageLoaderWithFallbackComposit(
                    primaryLoader: localImageLoader,
                    fallbackLoader: remoteCachingFeedImageLoader
                )
                
                let feedViewController = FeedUIComposer.makeFeedViewController(
                    loader: combinedFeedLoader,
                    imageLoader: imageLoader
                )
        
        window.rootViewController = feedViewController
        window.makeKeyAndVisible()
        
        self.window = window
    }
        
    func makeHTTPClient(isOffline: Bool) -> HTTPClient {
        guard !isOffline else {
            return AlwaysFailingHTTPClient()
        }
        
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        
        return client
    }
}

class AlwaysFailingHTTPClient: HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(.failure(NSError(domain: "OFFLINE", code: 0)))
        
        return AnyTask()
    }
    
    class AnyTask: HTTPClientTask {
        func cancel() {}
    }
}
