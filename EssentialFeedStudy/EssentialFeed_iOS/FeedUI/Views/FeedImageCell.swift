//
//  FeedImageCell.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit

public class FeedImageCell: UITableViewCell {
    @IBOutlet public var locationLabel: UILabel!
    @IBOutlet public var descriptionLabel: UILabel!
    @IBOutlet public var locationContainer: UIView!
    @IBOutlet public var imageContainer: UIView!
    @IBOutlet public var feedImageView: UIImageView!
    @IBOutlet public var retryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction func retryAction() {
        self.onRetry?()
    }
}
