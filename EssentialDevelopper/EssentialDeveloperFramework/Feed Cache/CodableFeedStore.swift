//
//  CodableFeedStore.swift
//  EssentialDeveloperFramework
//
//  Created by Andre Kvashuk on 6/7/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

public class CodableFeedStore: FeedStore {
    
    private struct FeedContainer: Codable {
        let feed: [CodableFeedImage]
        let timestamp: Date
    }
    
    private struct CodableFeedImage: Codable {
        public let id: UUID
        public let description: String?
        public let location: String?
        public let url: URL
        
        var local: LocalFeedImage {
            LocalFeedImage(id: id, description: description, location: location, url: url)
        }
        
        init(local: LocalFeedImage) {
            self.id = local.id
            self.description = local.description
            self.url = local.url
            self.location = local.location
        }
    }
    
    private let storeURL: URL
    private let queue = DispatchQueue(label: "CodableFeedStore", qos: .userInitiated, attributes: .concurrent)
    
    public init(storeURL: URL) {
        self.storeURL = storeURL
    }
    
    public func retrieve(_ completion: @escaping FeedStore.RetrieveCompletion) {
        let storeURL = self.storeURL
        queue.async {
            guard let data = try? Data(contentsOf: storeURL) else {
                return completion(.empty)
            }
            
            let decoder = JSONDecoder()
            
            do {
                let decoded = try decoder.decode(FeedContainer.self, from: data)
                completion(.success(feed: decoded.feed.map { $0.local }, timestamp: decoded.timestamp))
            } catch {
                completion(.failure(error))
            }
        }
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping FeedStore.TransactionCompletion) {
        let storeURL = self.storeURL
        
        queue.async(flags: .barrier) {
            do {
                let encoder = JSONEncoder()
                let encoded = try! encoder.encode(FeedContainer(feed: feed.map(CodableFeedImage.init), timestamp: timestamp))
                
                try encoded.write(to: storeURL)
                
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
    
    public func deleteCachedFeed(completion: @escaping FeedStore.TransactionCompletion) {
        let storeURL = self.storeURL
        
        queue.async(flags: .barrier) {
            guard FileManager.default.fileExists(atPath: storeURL.path) else {
                return completion(nil)
            }
            
            do {
                try FileManager.default.removeItem(at: storeURL)
                completion(nil)
            } catch {
                completion(error)
            }
        }
    }
}
