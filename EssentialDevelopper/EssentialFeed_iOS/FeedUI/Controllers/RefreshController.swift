//
//  RefreshController.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit

protocol RefreshControllerDelegate {
    func didRequestFeedLoad()
}

class RefreshController: NSObject {
    var delegate: RefreshControllerDelegate?
    
    @IBOutlet var view: UIRefreshControl?
    
    @IBAction func refresh() {
        self.delegate?.didRequestFeedLoad()
    }
}

extension RefreshController: LoaderView {
    func display(uiModel: FeedLoaderUIModel) {
        if uiModel.isLoading {
            view?.beginRefreshing()
        } else {
            view?.endRefreshing()
        }
    }
}
