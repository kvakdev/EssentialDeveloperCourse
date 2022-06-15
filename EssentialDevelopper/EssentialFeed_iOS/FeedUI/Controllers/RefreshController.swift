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
    private let delegate: RefreshControllerDelegate
    
    lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }()
    
    init(delegate: RefreshControllerDelegate) {
        self.delegate = delegate
    }
    
    @objc func refresh() {
        self.delegate.didRequestFeedLoad()
    }
}

extension RefreshController: LoaderView {
    func display(uiModel: FeedLoaderUIModel) {
        if uiModel.isLoading {
            view.beginRefreshing()
        } else {
            view.endRefreshing()
        }
    }
}
