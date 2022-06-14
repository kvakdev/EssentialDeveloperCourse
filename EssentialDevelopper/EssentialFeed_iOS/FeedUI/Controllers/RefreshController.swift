//
//  RefreshController.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit

class RefreshController: NSObject {
    private let loadFeed: () -> Void
    
    lazy var view: UIRefreshControl = {
        let view = UIRefreshControl()
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        return view
    }()
    
    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    }
    
    @objc func refresh() {
        loadFeed()
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
