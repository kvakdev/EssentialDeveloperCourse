//
//  FeedViewController.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/10/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit
import EssentialFeed


public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    var refreshController: RefreshController?
    var tableModel: [FeedImageCellController] = [] {
        didSet { tableView.reloadData() }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.refreshControl = refreshController?.view
        self.tableView.prefetchDataSource = self
        refreshController?.load()
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(at: indexPath).makeView()
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(at: indexPath).cancelTask()
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            _ = cellController(at: $0).makeView()
        }
    }
    
    private func cellController(at indexPath: IndexPath) -> FeedImageCellController {
        let cellController = tableModel[indexPath.row]
        
        return cellController
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cellController(at: $0).cancelTask() }
    }
}

