//
//  FeedImageCellController.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit
import EssentialFeed

class FeedImageCellController {
    var task: FeedImageDataLoaderTask?
    let model: FeedImage
    let imageLoader: FeedImageLoader
    
    init(model: FeedImage, imageLoader: FeedImageLoader) {
        self.imageLoader = imageLoader
        self.model = model
    }
    
    func makeView() -> FeedImageCell {
        let cell = FeedImageCell()
        
        cell.retryButton.isHidden = true
        cell.feedImageView.image = nil
        cell.locationContainer.isHidden = model.location == nil
        cell.descriptionLabel.text = model.description
        cell.locationLabel.text = model.location
        cell.imageContainer.startShimmering()
        
        let loadImage: () -> Void = { [weak self] in
            guard let self = self else { return }
            
            self.task = self.imageLoader.loadImage(with: self.model.url) { result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell.feedImageView.image = image
                cell.retryButton.isHidden = image != nil
                cell.imageContainer.stopShimmering()
            }
        }
        
        loadImage()
        cell.onRetry = loadImage
        
        return cell
    }
    
    func cancelTask() {
        task?.cancel()
        task = nil
    }
}
