//
//  FeedLoaderUIModel.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public struct FeedLoaderViewModel {
    public let isLoading: Bool
    public let errorMessage: String?
    
    static var loading: FeedLoaderViewModel {
        FeedLoaderViewModel(isLoading: true, errorMessage: nil)
    }
    
    static var noError: FeedLoaderViewModel {
        FeedLoaderViewModel(isLoading: false, errorMessage: nil)
    }
    
    static func loadingError(_ message: String) -> FeedLoaderViewModel {
        FeedLoaderViewModel(isLoading: false, errorMessage: message)
    }
}
