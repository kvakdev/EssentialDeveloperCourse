//
//  FeedImageCellController.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit

protocol FeedImageCellControllerDelegate {
    func didRequestToLoadImage()
    func didCancelTask()
}

class FeedImageCellController: FeedImageView {
    let cell = FeedImageCell()
    let delegate: FeedImageCellControllerDelegate
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func display(model: FeedImageUIModel<UIImage>) {
        cell.retryButton.isHidden = !model.isRetryVisible
        cell.feedImageView.image = model.image
        cell.locationContainer.isHidden = model.isLocationHidden
        cell.descriptionLabel.text = model.description
        cell.locationLabel.text = model.location
        cell.imageContainer.isShimmering = model.isLoading
        cell.onRetry = delegate.didRequestToLoadImage
    }
    
    func makeView() -> FeedImageCell {
        preload()
        
        return cell
    }
    
    func preload() {
        delegate.didRequestToLoadImage()
    }
    
    func cancelTask() {
        delegate.didCancelTask()
    }
}
