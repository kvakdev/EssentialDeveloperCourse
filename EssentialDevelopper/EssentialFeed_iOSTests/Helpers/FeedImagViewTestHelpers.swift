//
//  FeedImagViewTestHelpers.swift
//  EssentialFeed_iOSTests
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit
import EssentialFeed_iOS

extension FeedImageCell {
    var descriptionText: String? {
        descriptionLabel.text
    }
    
    var locationText: String? {
        locationLabel.text
    }
    
    var isShowingLocation: Bool {
        !locationContainer.isHidden
    }
    
    var isShowingImageLoadingIndicator: Bool {
        return imageContainer.isShimmering
    }
    
    var renderedImage: Data? {
        return feedImageView.image?.pngData()
    }
    
    var showsRetryAction: Bool {
        return retryButton.isHidden == false
    }
    
    func simulateRetryTap() {
        self.retryButton.simulateTap()
    }
}
