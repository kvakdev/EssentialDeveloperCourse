//
//  FeedCachePolicy.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 6/6/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

internal final class FeedCachePolicy {
    private static var maxAgeInDays: Int = 7
    private static let calendar = Calendar(identifier: .gregorian)
    
    private init() {}
    
    internal static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCachedAge = calendar.date(byAdding: .day, value: maxAgeInDays, to: timestamp) else {
            return false
        }
        
        return date < maxCachedAge
    }
}
