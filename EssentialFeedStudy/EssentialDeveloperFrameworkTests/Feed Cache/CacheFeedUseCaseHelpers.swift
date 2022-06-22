//
//  CacheFeedUseCaseHelpers.swift
//  EssentialFeedTests
//
//  Created by Andre Kvashuk on 6/5/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed


func uniqueFeed() -> (local: LocalFeedImage, model: FeedImage) {
    let local = LocalFeedImage(id: UUID(), url: anyURL())
    let model = FeedImage(id: local.id, description: local.description, location: local.location, imageUrl: local.url)
    
    return (local, model)
}

func uniqueFeedImage() -> FeedImage {
    return FeedImage(id: UUID(), imageUrl: anyURL())
}

extension Date {
    func minusMaxCacheAge() -> Date {
        return adding(days: -maxCacheAgeInDays)
    }
    
    private var maxCacheAgeInDays: Int {
        return 7
    }
    
    private func adding(days: Int) -> Date {
        return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    
    func adding(seconds: TimeInterval) -> Date {
        return addingTimeInterval(seconds)
    }
    
}
