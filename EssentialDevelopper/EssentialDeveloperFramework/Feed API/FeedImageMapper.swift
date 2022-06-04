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
    
    internal static func map(_ response: HTTPURLResponse, data: Data) -> RemoteFeedLoader.Result {
        
        guard response.statusCode == OK,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
                return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feed)
    }
}

private class Root: Decodable {
    let items: [Item]
    
    var feed: [FeedImage] {
        return items.map { $0.feedItem }
    }
}

private struct Item: Decodable, Equatable {
    public let id: UUID
    public let description: String?
    public let location: String?
    public let image: URL
    
    var feedItem: FeedImage {
        return FeedImage(id: self.id, description: self.description, location: self.location, imageUrl: self.image)
    }
    
    public init(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) {
        self.id = id
        self.description = description
        self.image = imageUrl
        self.location = location
    }
}
