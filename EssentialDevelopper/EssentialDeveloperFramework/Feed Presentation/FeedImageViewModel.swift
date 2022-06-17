//
//  FeedImageViewModel.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let isLocationHidden: Bool
    public let isLoading: Bool
    public let image: Image?
    public let isRetryVisible: Bool
}
