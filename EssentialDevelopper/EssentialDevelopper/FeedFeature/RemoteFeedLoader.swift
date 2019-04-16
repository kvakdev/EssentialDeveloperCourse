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
                let result = RemoteFeedLoader.handle(response: response, data: data)
                completion(result)
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
    
    private static func handle(response: HTTPURLResponse, data: Data) -> Result {
        if let items = try? FeedItemMapper.map(response: response, data: data) {
            return .success(items)
        }
        
        return .failure(.invalidData)
    }
}
