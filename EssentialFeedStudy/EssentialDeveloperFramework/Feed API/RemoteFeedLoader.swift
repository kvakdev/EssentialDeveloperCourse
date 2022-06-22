//
//  RemoteFeedLoader.swift
//  EssentialDevelopper
//
//  Created by Andre Kvashuk on 4/15/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public final class RemoteFeedLoader: FeedLoader {
    
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    public typealias Result = FeedLoader.Result
        
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> ()) {
        client.get(from: url) { [weak self] result in
            guard self != nil else { return }
            
            switch result {
            case .success((let response, let data)):
                do {
                    let result = try FeedImageMapper.map(response, data: data)
                    completion(.success(result.toModels()))
                } catch {
                    completion(.failure(error))
                }
                
            case .failure:
                completion(.failure(Error.connectivity))
            }
        }
    }
}

private extension Array where Element == RemoteFeedItem {
    func toModels() -> [FeedImage] {
        compactMap { FeedImage(id: $0.id,
                               description: $0.description,
                               location: $0.location,
                               imageUrl: $0.image) }
    }
}
