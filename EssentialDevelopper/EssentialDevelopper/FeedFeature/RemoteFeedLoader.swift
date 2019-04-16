//
//  RemoteFeedLoader.swift
//  EssentialDevelopper
//
//  Created by Andre Kvashuk on 4/15/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public enum HTTPClientResult {
    case success(HTTPURLResponse, Data)
    case failure(Error)
}

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> ())
}

public final class RemoteFeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public enum Result: Equatable {
        case failure(Error)
        case success([FeedItem])
    }
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> ()) {
        client.get(from: url) { result in
            switch result {
            case .success(let response, let data):
                guard let items = try? FeedItemMapper.map(response: response, data: data) else {
                    completion(.failure(.invalidData))
                    return
                }
                completion(.success(items))
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
}

private class FeedItemMapper {
    private struct Item: Decodable, Equatable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let image: URL
        
        var feedItem: FeedItem {
            return FeedItem(id: self.id, description: self.description, location: self.location, imageUrl: self.image)
        }
        
        public init(id: UUID, description: String? = nil, location: String? = nil, imageUrl: URL) {
            self.id = id
            self.description = description
            self.image = imageUrl
            self.location = location
        }
    }
    
    private static let OK = Int(200)
    
    public static func map(response: HTTPURLResponse, data: Data) throws -> [FeedItem] {
        
        class Root: Decodable {
            let items: [Item]
        }
        
        guard response.statusCode == OK,
            let root = try? JSONDecoder().decode(Root.self, from: data) else {
                throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items.map { $0.feedItem }
    }
}

