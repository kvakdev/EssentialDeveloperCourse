//
//  RemoteFeedLoader.swift
//  EssentialDevelopper
//
//  Created by Andre Kvashuk on 4/15/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPURLResponse?, Error?) -> ())
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
        client.get(from: url) { response, error in
            if let error = error {
                completion(Error.connectivity)
            } else if response?.statusCode != 200 {
                completion(Error.invalidData)
            }
        }
    }
    
}
