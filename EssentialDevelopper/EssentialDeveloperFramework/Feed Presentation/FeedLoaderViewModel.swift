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
    
    static var loading: FeedLoaderViewModel {
        FeedLoaderViewModel(isLoading: true)
    }
    
    static var notLoading: FeedLoaderViewModel {
        FeedLoaderViewModel(isLoading: false)
    }
}
