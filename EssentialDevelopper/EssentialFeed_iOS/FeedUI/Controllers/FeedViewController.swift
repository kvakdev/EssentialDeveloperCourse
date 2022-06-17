//
//  FeedViewController.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/10/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit

protocol FeedViewControllerDelegate {
    func didRequestFeedLoad()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, LoaderView {
    var delegate: FeedViewControllerDelegate?

    var tableModel: [FeedImageCellController] = [] {
        didSet { tableView.reloadData() }
    }
 
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh()
    }
    
    @IBAction func refresh() {
        self.delegate?.didRequestFeedLoad()
    }
    
    func display(uiModel: FeedLoaderUIModel) {
        if uiModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
        tableView.handleFeedLoadingError(uiModel.errorMessage)
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(at: indexPath).makeView(tableView: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cellController(at: indexPath).cancelTask()
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            _ = cellController(at: $0).makeView(tableView: tableView)
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

extension UITableView {
    func handleFeedLoadingError(_ message: String?) {
        if let error = message {
            let headerView = FeedErrorHeaderView(errorMessage: error)
            tableHeaderView = headerView
        } else {
            tableHeaderView = nil
        }
    }
}
