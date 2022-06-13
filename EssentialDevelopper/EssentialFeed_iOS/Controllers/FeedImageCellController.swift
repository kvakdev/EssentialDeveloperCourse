//
//  FeedImageCellController.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit

class FeedImageCellController {
    let viewModel: FeedImageCellViewModel<UIImage>
    
    init(viewModel: FeedImageCellViewModel<UIImage>) {
        self.viewModel = viewModel
    }
    
    func makeView() -> FeedImageCell {
        let cell = FeedImageCell()
        
        cell.retryButton.isHidden = true
        cell.feedImageView.image = nil
        cell.locationContainer.isHidden = viewModel.isLocationHidden
        cell.descriptionLabel.text = viewModel.description
        cell.locationLabel.text = viewModel.location
        
        viewModel.onImageLoad = { image in
            cell.feedImageView.image = image
         }
        viewModel.onRetryStateChange = { visible in
            cell.retryButton.isHidden = !visible
        }
        viewModel.onIsLoadingStateChange = { isLoading in
            cell.imageContainer.isShimmering = isLoading
        }
        cell.onRetry = { [weak self] in self?.viewModel.loadImage() }
        viewModel.loadImage()
        
        return cell
    }
    
    func cancelTask() {
        viewModel.cancelTask()
    }
}
