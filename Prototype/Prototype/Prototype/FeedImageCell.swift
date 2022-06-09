//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Andre Kvashuk on 6/9/22.
//

import UIKit

class FeedImageCell: UITableViewCell {
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var locationContainer: UIStackView!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var feedImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        self.feedImageView.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.feedImageView.alpha = 0
    }
    
    func fadeInAnImage(_ image: UIImage?) {
        self.feedImageView?.image = image
        
        UIView.animate(withDuration: 0.4, delay: 0.3, options: .curveEaseOut) {
            self.feedImageView.alpha = 1
        }

    }
    
}

extension FeedImageCell {
    func setupWith(_ viewModel: FeedImageViewModel) {
        locationLabel.text = viewModel.location
        descriptionLabel.text = viewModel.description
        
        locationContainer.isHidden = viewModel.location == nil
        descriptionLabel.isHidden = viewModel.description == nil
        let image = UIImage(named: viewModel.imageName)
        fadeInAnImage(image)
    }
}
