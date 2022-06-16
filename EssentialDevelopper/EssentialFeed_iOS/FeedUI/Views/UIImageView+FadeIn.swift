//
//  UIImageView+FadeIn.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/16/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit

extension UIImageView {
    func setImageAnimated(_ newImage: UIImage?) {
        self.image = newImage
        
        guard newImage != nil else { return }
        
        alpha = 0
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
}
