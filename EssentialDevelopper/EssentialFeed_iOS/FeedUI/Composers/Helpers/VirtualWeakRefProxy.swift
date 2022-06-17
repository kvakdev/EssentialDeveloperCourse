//
//  VirtualWeakRefProxy.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/16/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed

class VirtualWeakRefProxy<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension VirtualWeakRefProxy: FeedView where T: FeedView {
    func display(model: FeedViewModel) {
        object?.display(model: model)
    }
}

extension VirtualWeakRefProxy: LoaderView where T: LoaderView {
    func display(uiModel: FeedLoaderViewModel) {
        object?.display(uiModel: uiModel)
    }
}

extension VirtualWeakRefProxy: ErrorView where T: ErrorView {
    func display(model: FeedErrorViewModel) {
        object?.display(model: model)
    }
}

extension VirtualWeakRefProxy: FeedImageView where T: FeedImageView {
    func display(model: FeedImageViewModel<T.Image>) {
        object?.display(model: model)
    }
}
