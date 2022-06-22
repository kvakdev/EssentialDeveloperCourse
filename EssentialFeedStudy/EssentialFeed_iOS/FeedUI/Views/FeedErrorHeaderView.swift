//
//  FeedErrorHeaderView.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit

public class FeedErrorHeaderView: UIView {
    private(set) public var titleLabel = UILabel()
    
    convenience init(errorMessage: String) {
        self.init(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 30))
        titleLabel.text = errorMessage
    }
}
