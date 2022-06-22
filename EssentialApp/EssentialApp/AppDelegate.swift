//
//  AppDelegate.swift
//  EssentialApp
//
//  Created by Andre Kvashuk on 6/22/22.
//

import UIKit
import EssentialFeed
import EssentialFeed_iOS

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let url = URL(string: "https://ile-api.essentialdeveloper.com/essential-feed/v1/feed")!
        let session = URLSession(configuration: .ephemeral)
        let client = URLSessionHTTPClient(session: session)
        let feedImageLoader = RemoteFeedImageLoader(client: client)
        let feeeedLoader = RemoteFeedLoader(url: url, client: client)
        
        let feedViewController = FeedUIComposer.makeFeedViewController(
            loader: feeeedLoader,
            imageLoader: feedImageLoader
        )
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = feedViewController
        window?.makeKeyAndVisible()
        
        return true
    }

}

