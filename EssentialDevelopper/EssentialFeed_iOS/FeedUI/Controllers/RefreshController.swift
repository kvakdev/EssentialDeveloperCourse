//
//  RefreshController.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit

class RefreshController: NSObject {
    var presenter: FeedPresenter?

    lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }()
    
    @objc func refresh() {
        presenter?.loadFeed()
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
