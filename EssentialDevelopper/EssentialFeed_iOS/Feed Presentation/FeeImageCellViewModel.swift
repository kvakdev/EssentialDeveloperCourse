//
//  FeeImageCellViewModel.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/13/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed

struct FeedImageUIModel<Image> {
    var description: String?
    var location: String?
    var isLocationHidden: Bool
    var isLoading: Bool
    var image: Image?
    var isRetryVisible: Bool
}

protocol FeedImageView {
    associatedtype Image
    func display(model: FeedImageUIModel<Image>)
}

class FeedImageCellPresenter<View: FeedImageView, Image> where View.Image == Image {
    private let view: View
    private let transformer: (Data) -> Image?

    var task: FeedImageDataLoaderTask?
    
    init(view: View, transformer: @escaping (Data) -> Image?) {
        self.view = view
        self.transformer = transformer
    }
    
    func didStartLoading(for model: FeedImage) {
        view.display(model: FeedImageUIModel(description: model.description,
                                             location: model.location,
                                             isLocationHidden: model.location == nil,
                                             isLoading: true,
                                             image: nil,
                                             isRetryVisible: false))
    }
    
    private struct InvalidDataError: Error {}
    
    func didCompleteLoading(data: Data, for model: FeedImage) {
        guard let image = transformer(data) else {
            view.display(model: FeedImageUIModel(description: model.description,
                                                 location: model.location,
                                                 isLocationHidden: model.location == nil,
                                                 isLoading: false,
                                                 image: nil,
                                                 isRetryVisible: true))
            return
        }
        
        view.display(model: FeedImageUIModel(description: model.description,
                                             location: model.location,
                                             isLocationHidden: model.location == nil,
                                             isLoading: false,
                                             image: image,
                                             isRetryVisible: false))
    }
    
    func didFailLoading(error: Error, for model: FeedImage) {
        view.display(model: FeedImageUIModel(description: model.description,
                                             location: model.location,
                                             isLocationHidden: model.location == nil,
                                             isLoading: false,
                                             image: nil,
                                             isRetryVisible: true))
    }
}
