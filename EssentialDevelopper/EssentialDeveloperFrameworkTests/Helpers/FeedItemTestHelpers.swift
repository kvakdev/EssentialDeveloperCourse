//
//  FeedItemTestHelpers.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 4/26/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation
import  EssentialDeveloperFramework

func uniqueFeedItem() -> FeedImage {
    return FeedImage(id: UUID(), imageUrl: URL(string: "http://any-url.com")!)
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let array = [uniqueFeedItem()]
    
    return (array, array.toLocal())
}

func anyNSError() -> NSError {
    return NSError(domain: "CacheFeedError", code: 1, userInfo: nil)
}

internal extension Date {
    func addingDays(_ amount: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: amount, to: self)!
    }
    
    func addingSeconds(_ amount: TimeInterval) -> Date {
        return self.addingTimeInterval(amount)
    }
}
