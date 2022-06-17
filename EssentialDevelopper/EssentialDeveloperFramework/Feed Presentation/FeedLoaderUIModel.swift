//
//  FeedLoaderUIModel.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public struct FeedLoaderUIModel {
    public let isLoading: Bool
    public let errorMessage: String?
    
    static var loading: FeedLoaderUIModel {
        FeedLoaderUIModel(isLoading: true, errorMessage: nil)
    }
    
    static var noError: FeedLoaderUIModel {
        FeedLoaderUIModel(isLoading: false, errorMessage: nil)
    }
    
    static func loadingError(_ message: String) -> FeedLoaderUIModel {
        FeedLoaderUIModel(isLoading: false, errorMessage: message)
    }
}
