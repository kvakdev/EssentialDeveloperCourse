//
//  URLSessionHTTPClient.swift
//  EssentialDevelopper
//
//  Created by Andre Kvashuk on 4/19/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

public class URLSessionHTTPClient: HTTPClient {
    let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    struct UnexpectedRepresentationError: Error {}
    
    public func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) {
        self.session.dataTask(with: url, completionHandler: { data, response, error in
            if let error = error {
                completion(.failure(error))
            } else if let data = data, let response = response as? HTTPURLResponse {
                completion(.success((response, data)))
            } else {
                completion(.failure(UnexpectedRepresentationError()))
            }
        }).resume()
    }
}
