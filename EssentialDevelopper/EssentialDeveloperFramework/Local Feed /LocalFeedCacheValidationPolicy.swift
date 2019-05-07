//
//  LocalFeedCacheValidationPolicy.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 5/7/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public protocol DateValidationProtocol {
    func isValidTimestamp(_ timestamp: Date, against date: Date) -> Bool
}

public class LocalFeedValidationPolicy: DateValidationProtocol {
    public init() {}
    
    private let maxAgeInDays = 7
    
    public func isValidTimestamp(_ timestamp: Date, against date: Date) -> Bool {
        let expirationDate = timestamp.addingDays(maxAgeInDays)
        
        return expirationDate > date
    }
}

fileprivate extension Date {
    func addingDays(_ amount: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(day: amount), to: self)!
    }
}
