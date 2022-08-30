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
    
    lazy var feedStore: FeedStore & ImageStore = try! CoreDataFeedStore(storeURL: storeURL)
    lazy var client = makeHTTPClient()
    lazy var localFeedLoader = LocalFeedLoader(feedStore) { Date() }
    
    private let storeURL = NSPersistentContainer.defaultDirectoryURL()
        .appendingPathComponent("Feed-store.sqlite")
    
    convenience init(feedStore: FeedStore & ImageStore, client: HTTPClient) {
        self.init()
        self.feedStore = feedStore
        self.client = client
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = scene as? UIWindowScene else { return }
        window = UIWindow(windowScene: scene)
        
        setup()
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        localFeedLoader.validateCache(completion: { _ in })
    }
    
    func setup() {
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        
        let remoteImageLoader = RemoteFeedImageLoader(client: client)

        let localImageLoader = LocalFeedImageLoader(store: feedStore)
        let remoteCachingFeedImageLoader = FeedImageLoaderCachingDecorator(remoteImageLoader, cache: localImageLoader)
        
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
        
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
        
        window?.rootViewController = UINavigationController(rootViewController: feedViewController)
        window?.makeKeyAndVisible()
    }
        
    func makeHTTPClient() -> HTTPClient {
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        
        return client
    }
}
