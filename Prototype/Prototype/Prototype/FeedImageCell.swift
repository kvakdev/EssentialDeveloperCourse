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
    @IBOutlet var imageContainer: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        self.feedImageView.alpha = 0
        self.imageContainer.startShimmering()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.feedImageView.alpha = 0
        self.imageContainer.startShimmering()
        
    }
    
    func fadeInAnImage(_ image: UIImage?) {
        self.feedImageView?.image = image
        
        UIView.animate(
            withDuration: 0.25,
            delay: 1.2,
            options: .curveEaseOut,
            animations: {
                self.feedImageView.alpha = 1
            }) { isCompleted in
                if isCompleted {
                    self.imageContainer.stopShimmering()
                }
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

private extension UIView {
     private var shimmerAnimationKey: String {
         return "shimmer"
     }

     func startShimmering() {
         let white = UIColor.white.cgColor
         let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
         let width = bounds.width
         let height = bounds.height

         let gradient = CAGradientLayer()
         gradient.colors = [alpha, white, alpha]
         gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
         gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
         gradient.locations = [0.4, 0.5, 0.6]
         gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
         layer.mask = gradient

         let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
         animation.fromValue = [0.0, 0.1, 0.2]
         animation.toValue = [0.8, 0.9, 1.0]
         animation.duration = 1
         animation.repeatCount = .infinity
         gradient.add(animation, forKey: shimmerAnimationKey)
     }

     func stopShimmering() {
         layer.mask = nil
     }
 }
