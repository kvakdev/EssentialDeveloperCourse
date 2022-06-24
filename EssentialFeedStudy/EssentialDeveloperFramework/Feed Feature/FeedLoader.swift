//
//  FeedLoader.swift
//  EssentialDevelopper
//
//  Created by Andre Kvashuk on 4/16/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation


public protocol FeedLoader: AnyObject {
    typealias Result = Swift.Result<[FeedImage], Error>
    
    func load(completion: @escaping (Result) -> ())
}

public protocol FeedCache {
    typealias SaveResult = Result<Void, Error>
    
    func save(_ feedImages: [FeedImage], completion: @escaping (SaveResult) -> Void)
}
