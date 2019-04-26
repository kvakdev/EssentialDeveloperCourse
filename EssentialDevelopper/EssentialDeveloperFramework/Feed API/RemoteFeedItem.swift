//
//  RemoteFeedItem.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 4/26/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

internal struct RemoteFeedItem: Decodable, Equatable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
    
    public init(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) {
        self.id = id
        self.description = description
        self.image = imageUrl
        self.location = location
    }
}

