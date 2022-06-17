//
//  FeedImageCellPresenter.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation


public struct FeedImageViewModel<Image> {
    public let description: String?
    public let location: String?
    public let isLocationHidden: Bool
    public let isLoading: Bool
    public let image: Image?
    public let isRetryVisible: Bool
}

public protocol FeedImageView {
    associatedtype Image
    func display(model: FeedImageViewModel<Image>)
}


public class FeedImageCellPresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private let view: View
    private let transformer: (Data) -> Image?
    
    
    public init(view: View, transformer: @escaping (Data) -> Image?) {
        self.view = view
        self.transformer = transformer
    }
    
    public func didStartLoading(for model: FeedImage) {
        view.display(model: FeedImageViewModel(description: model.description,
                                             location: model.location,
                                             isLocationHidden: model.location == nil,
                                             isLoading: true,
                                             image: nil,
                                             isRetryVisible: false))
    }
    
    
    public func didCompleteLoading(data: Data, for model: FeedImage) {
        guard let image = transformer(data) else {
            view.display(model: FeedImageViewModel(description: model.description,
                                                 location: model.location,
                                                 isLocationHidden: model.location == nil,
                                                 isLoading: false,
                                                 image: nil,
                                                 isRetryVisible: true))
            return
        }
        
        view.display(model: FeedImageViewModel(description: model.description,
                                             location: model.location,
                                             isLocationHidden: model.location == nil,
                                             isLoading: false,
                                             image: image,
                                             isRetryVisible: false))
    }
    
    public func didFailLoading(error: Error, for model: FeedImage) {
        view.display(model: FeedImageViewModel(description: model.description,
                                             location: model.location,
                                             isLocationHidden: model.location == nil,
                                             isLoading: false,
                                             image: nil,
                                             isRetryVisible: true))
    }
    
}
