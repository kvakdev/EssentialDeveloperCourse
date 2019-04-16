//
//  RemoteFeedLoader.swift
//  EssentialDevelopper
//
//  Created by Andre Kvashuk on 4/15/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

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
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success(let response, let data):
                let result = FeedItemMapper.map(response, data: data)
                completion(result)
            case .failure:
                completion(.failure(.connectivity))
            }
        }
    }
}
