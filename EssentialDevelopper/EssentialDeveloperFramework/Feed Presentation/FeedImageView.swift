//
//  FeedImageView.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public protocol FeedImageView {
    associatedtype Image
    
    func display(model: FeedImageViewModel<Image>)
}
