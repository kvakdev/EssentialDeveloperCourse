//
//  FeedItemTestHelpers.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 4/26/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import  EssentialDeveloperFramework

func uniqueFeedItem() -> FeedItem {
    return FeedItem(id: UUID(), imageUrl: URL(string: "http://any-url.com")!)
}

func uniqueFeedItems() -> (models: [FeedItem], local: [LocalFeedItem]) {
    let array = [uniqueFeedItem()]
    
    return (array, array.toLocal())
}

func anyNSError() -> NSError {
    return NSError(domain: "CacheFeedError", code: 1, userInfo: nil)
}
