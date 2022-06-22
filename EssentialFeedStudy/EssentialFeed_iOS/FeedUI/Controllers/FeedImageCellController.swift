//
//  FeedImageCellController.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit
import EssentialFeed

protocol FeedImageCellControllerDelegate {
    func didRequestToLoadImage()
    func didCancelTask()
}

class FeedImageCellController: FeedImageView {
    var cell: FeedImageCell?
    let delegate: FeedImageCellControllerDelegate
    
    init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func display(model: FeedImageViewModel<UIImage>) {
        cell?.retryButton.isHidden = !model.isRetryVisible
        cell?.feedImageView.setImageAnimated(model.image)
        cell?.locationContainer.isHidden = model.isLocationHidden
        cell?.descriptionLabel.text = model.description
        cell?.locationLabel.text = model.location
        cell?.imageContainer.isShimmering = model.isLoading
        cell?.onRetry = delegate.didRequestToLoadImage
    }
    
    func makeView(tableView: UITableView) -> FeedImageCell {
        self.cell = tableView.dequeueReusableCell()
        preload()
        
        return cell!
    }
    
    func preload() {
        delegate.didRequestToLoadImage()
    }
    
    func cancelTask() {
        releaseCellForReuse()
        delegate.didCancelTask()
    }
    
    private func releaseCellForReuse() {
        self.cell = nil
    }
}

extension UITableView {
    func dequeueReusableCell<T>(id: String = String(describing: type(of: T.self))) -> T where T: UITableViewCell {
        return dequeueReusableCell(withIdentifier: id) as! T
    }
}
