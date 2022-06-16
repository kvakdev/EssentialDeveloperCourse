//
//  FeedUIComposer.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed
import UIKit

public class FeedUIComposer {
    private init() {}
    
    public static func makeFeedViewController(loader: FeedLoader, imageLoader: FeedImageLoader) -> FeedViewController {
        
        let decotedMainThreadFeedloader = MainThreadDispatchDecorator(decoratee: loader)
        let presentationAdapter = FeedPresentationAdapter(loader: decotedMainThreadFeedloader)
        let feedViewController = makeFeedViewController(delegate: presentationAdapter, title: FeedPresenter.title)
        
        let adapter = FeedViewAdapter(feedViewController: feedViewController, imageLoader: MainThreadDispatchDecorator(decoratee: imageLoader))
        let presenter = FeedPresenter(view: adapter, loaderView: VirtualWeakRefProxy(feedViewController))
        
        presentationAdapter.delegate = presenter
        
        return feedViewController
    }
    
    private static func makeFeedViewController(delegate: FeedViewControllerDelegate, title: String) -> FeedViewController {
        let bundle = Bundle(for: FeedViewController.self)
        let feedViewController = UIStoryboard(name: "Feed", bundle: bundle).instantiateInitialViewController() as! FeedViewController
        feedViewController.title = title
     
        feedViewController.delegate = delegate
        
        return feedViewController
    }
}
