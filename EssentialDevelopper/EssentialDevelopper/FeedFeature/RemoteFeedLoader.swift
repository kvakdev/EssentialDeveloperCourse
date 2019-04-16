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
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Error) -> ()) {
        client.get(from: url) { result in
            switch result {
            case .success(let response, let data):
                guard let items = try? map(response: response, data: data) else {
                    completion(.invalidData)
                    return
                }
            case .failure:
                completion(.connectivity)
            }
        }
    }
    
}

public func map(response: HTTPURLResponse, data: Data) throws -> [FeedItem] {
    class Root: Decodable {
        let items: [FeedItem]
    }
    
    guard response.statusCode != 200,
        let root = try? JSONDecoder().decode(Root.self, from: data) else {
            throw RemoteFeedLoader.Error.invalidData
    }
    
    return root.items
}

