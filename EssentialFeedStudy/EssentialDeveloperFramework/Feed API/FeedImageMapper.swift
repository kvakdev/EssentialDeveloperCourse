//
//  FeedImageMapper.swift
//  EssentialDevelopper
//
//  Created by Andre Kvashuk on 4/16/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

internal final class FeedImageMapper {
    private static let OK = Int(200)
    
    internal static func map(_ response: HTTPURLResponse, data: Data) throws -> [RemoteFeedItem] {
        
        guard response.statusCode == OK,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
                throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}

private class Root: Decodable {
    let items: [RemoteFeedItem]
}

internal struct RemoteFeedItem: Decodable, Equatable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
    
    internal init(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) {
        self.id = id
        self.description = description
        self.image = imageUrl
        self.location = location
    }
}
