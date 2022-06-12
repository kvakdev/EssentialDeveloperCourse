//
//  RefreshController.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit

class RefreshController: NSObject {
    let viewModel: RefreshViewModel
    
    init(viewModel: RefreshViewModel) {
        self.viewModel = viewModel
    }
    
    lazy var view: UIRefreshControl = binded(UIRefreshControl())
    
    func binded(_ view: UIRefreshControl) -> UIRefreshControl {
        let view = UIRefreshControl()
        
        view.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        viewModel.onIsLoadingChange = { isLoading in
            if isLoading {
                view.beginRefreshing()
            } else {
                view.endRefreshing()
            }
        }
        
        return view
    }
    
    @objc func refresh() {
        viewModel.loadFeed()
    }
}
