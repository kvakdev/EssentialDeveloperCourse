//
//  FeedItem.swift
//  EssentialDevelopper
//
//  Created by Andre Kvashuk on 4/16/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public struct FeedItem: Decodable, Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
}
