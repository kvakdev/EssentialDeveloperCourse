//
//  RemoteFeedLoaderProtocol.swift
//  EssentialDevelopperTests
//
//  Created by Andre Kvashuk on 4/15/19.
//  Copyright © 2019 Andre Kvashuk. All rights reserved.
//

import Foundation

struct FeedItem {
}

protocol FeedLoader {
    func load(url: URL, completion: @escaping ([FeedItem], Error?) -> ())
}
