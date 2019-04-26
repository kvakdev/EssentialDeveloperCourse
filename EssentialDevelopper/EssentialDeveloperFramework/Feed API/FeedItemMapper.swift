//
//  FeedItemMapper.swift
//  EssentialDevelopper
//
//  Created by Andre Kvashuk on 4/16/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

internal final class FeedItemMapper {
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
