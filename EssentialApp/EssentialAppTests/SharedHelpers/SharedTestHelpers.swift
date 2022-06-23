//
//  SharedTestHelpers.swift
//  EssentialAppTests
//
//  Created by Andre Kvashuk on 6/23/22.
//

import Foundation
import EssentialFeed

func uniqueFeed() -> [FeedImage] {
    [FeedImage(id: UUID(),
               description: nil,
               location: nil,
               imageUrl: anyURL())]
}

func anyURL() -> URL {
    URL(string: "http://any-url.com")!
}

func anyError(code: Int = 0) -> NSError {
    NSError(domain: "CompositLoaderTests", code: code)
}
