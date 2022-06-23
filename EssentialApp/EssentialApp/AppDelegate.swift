//
//  AppDelegate.swift
//  EssentialApp
//
//  Created by Andre Kvashuk on 6/22/22.
//

import UIKit
import EssentialFeed
import EssentialFeed_iOS
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let storeURL = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent("Feed-store.sqlite")
        let feedStore = try! CoreDataFeedStore(storeURL: storeURL)
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        
        let remoteImageLoader = RemoteFeedImageLoader(client: client)
        let localImageLoader = LocalFeedImageLoader(store: feedStore)
        
        let remoteFeedLoader = RemoteFeedLoader(url: url, client: client)
        let localFeedLoader = LocalFeedLoader(feedStore) { Date() }
        
        let combinedFeedLoader = FeedLoaderWithFallbackComposit(
            primary: remoteFeedLoader,
            fallback: localFeedLoader
        )
        let imageLoader = ImageLoaderWithFallbackComposit(
            primaryLoader: remoteImageLoader,
            fallbackLoader: localImageLoader
        )
        
        let feedViewController = FeedUIComposer.makeFeedViewController(
            loader: combinedFeedLoader,
            imageLoader: imageLoader
        )
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = feedViewController
        window?.makeKeyAndVisible()
        
        return true
    }

}

