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
    }

}

extension FeedImageCell {
    func setupWith(_ viewModel: FeedImageViewModel) {
        locationLabel.text = viewModel.location
        feedImageView.image = UIImage(named: viewModel.imageName)
        descriptionLabel.text = viewModel.description
        
        locationContainer.isHidden = viewModel.location == nil
        descriptionLabel.isHidden = viewModel.description == nil
    }
}
