//
//  FeedViewController.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/10/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit
import EssentialFeed

public protocol FeedViewControllerDelegate {
    func didRequestFeedLoad()
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching, LoaderView, ErrorView {
    public var delegate: FeedViewControllerDelegate?
    
    @IBOutlet private(set) var errorView: FeedErrorHeaderView!
    
    private var loadingControllers: [IndexPath: FeedImageCellController] = [:]
    
    private var tableModel: [FeedImageCellController] = [] {
        didSet { tableView.reloadData() }
    }
 
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        errorView.alpha = 0
        refresh()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.sizeTableHeaderToFit()
    }
    
    @IBAction func refresh() {
        self.delegate?.didRequestFeedLoad()
    }
    
    public func display(model: [FeedImageCellController]) {
        self.tableModel = model
    }
    
    public func display(uiModel: FeedLoaderViewModel) {
        if uiModel.isLoading {
            refreshControl?.beginRefreshing()
        } else {
            refreshControl?.endRefreshing()
        }
    }
    
    public func display(model: FeedErrorViewModel) {
        errorView.titleLabel.text = model.message
        errorView.alpha = model.message == nil ? 0 : 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return cellController(at: indexPath).makeView(tableView: tableView)
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelAt(indexPath: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            _ = cellController(at: $0).makeView(tableView: tableView)
        }
    }
    
    private func cellController(at indexPath: IndexPath) -> FeedImageCellController {
        let cellController = tableModel[indexPath.row]
        loadingControllers[indexPath] = cellController
        
        return cellController
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach { cancelAt(indexPath: $0) }
    }
    
    private func cancelAt(indexPath: IndexPath) {
        loadingControllers[indexPath]?.cancelTask()
        loadingControllers[indexPath] = nil
    }
}
