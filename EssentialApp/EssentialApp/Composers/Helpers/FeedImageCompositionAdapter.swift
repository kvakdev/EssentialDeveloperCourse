//
//  FeedImageCompositionAdapter.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/16/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed
import EssentialFeed_iOS

class FeedImageCompositionAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    
    private let imageLoader: FeedImageLoader
    private let model: FeedImage

    private var task: CancellableTask?
    
    var presenter: FeedImageCellPresenter<View, Image>?
    
    init(imageLoader: FeedImageLoader, model: FeedImage) {
        self.imageLoader = imageLoader
        self.model = model
    }
    
    func didRequestToLoadImage() {
        presenter?.didStartLoading(for: model)
        
        self.task = self.imageLoader.loadImage(with: self.model.url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.presenter?.didCompleteLoading(data: data, for: self.model)
            case .failure(let error):
                self.presenter?.didFailLoading(error: error, for: self.model)
            }
        }
    }
    func didCancelTask() {
        task?.cancel()
        task = nil
    }
    
    deinit { didCancelTask() }
}
