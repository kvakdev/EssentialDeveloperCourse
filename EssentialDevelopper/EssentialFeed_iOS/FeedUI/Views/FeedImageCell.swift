//
//  FeedImageCell.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit

public class FeedImageCell: UITableViewCell {
    public var locationLabel = UILabel()
    public var descriptionLabel = UILabel()
    public var locationContainer = UIView()
    public var imageContainer = UIView()
    public var feedImageView = UIImageView()
    
    public lazy var retryButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(retryAction), for: .touchUpInside)
        
        return button
    }()
    
    var onRetry: (() -> Void)?
    
    @objc
    func retryAction() {
        self.onRetry?()
    }
}
