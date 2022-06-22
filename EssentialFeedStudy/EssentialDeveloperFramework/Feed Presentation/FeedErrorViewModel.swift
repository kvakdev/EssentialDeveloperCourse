//
//  ErrorViewModel.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public struct FeedErrorViewModel {
    public let message: String?
    
    static var noError: FeedErrorViewModel { .init(message: nil) }
    
    static var feedLoadingError: FeedErrorViewModel {
       let feedLoadingError: String =
            NSLocalizedString("FEED_LOADING_ERROR",
                              tableName: "Feed",
                              bundle: Bundle(for: FeedPresenter.self),
                              value: "",
                              comment: "error after feed loading")
        
        return FeedErrorViewModel(message: feedLoadingError)
    }
}
