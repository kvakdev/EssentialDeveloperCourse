//
//  FeedViewController.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/10/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit
import EssentialFeed

//self?.tableModel = feed
//self?.tableView.reloadData()
class RefreshController: NSObject {
    let loader: FeedLoader
    let onRefresh: ([FeedImage]) -> Void
    
    init(loader: FeedLoader, onRefresh: @escaping ([FeedImage]) -> Void) {
        self.loader = loader
        self.onRefresh = onRefresh
    }
    
    lazy var view: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        
        return refreshControl
    }()
    
    @objc
    func load() {
        self.view.beginRefreshing()
        
        self.loader.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh(feed)
            }
            self?.view.endRefreshing()
        }
    }
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var imageLoader: FeedImageLoader?
    private var tasks: [IndexPath: FeedImageDataLoaderTask] = [:]
    private var refreshController: RefreshController?
    public var tableModel: [FeedImage] = [] {
        didSet { tableView.reloadData() }
    }
    
    public convenience init(loader: FeedLoader, imageLoader: FeedImageLoader) {
        self.init()
        self.imageLoader = imageLoader
        self.refreshController = RefreshController(loader: loader, onRefresh: { [weak self] feed in
            self?.tableModel = feed
        })
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        self.refreshControl = refreshController?.view
        refreshController?.load()
    }
    
    func setupTableView() {
        
        self.tableView.prefetchDataSource = self
    }

    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FeedImageCell()
        let cellModel = tableModel[indexPath.row]
        
        cell.retryButton.isHidden = true
        cell.feedImageView.image = nil
        cell.locationContainer.isHidden = cellModel.location == nil
        cell.descriptionLabel.text = cellModel.description
        cell.locationLabel.text = cellModel.location
        cell.imageContainer.startShimmering()
        
        let loadImage: () -> Void = { [weak self] in
            self?.tasks[indexPath] = self?.imageLoader?.loadImage(with: cellModel.url) { result in
                let data = try? result.get()
                let image = data.map(UIImage.init) ?? nil
                cell.feedImageView.image = image
                cell.retryButton.isHidden = image != nil
                cell.imageContainer.stopShimmering()
            }
        }
        
        loadImage()
        cell.onRetry = loadImage
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cancelTask(indexPath)
    }
    
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            let cellModel = tableModel[$0.row]
            tasks[$0] = imageLoader?.loadImage(with: cellModel.url, completion: { _ in })
        }
    }
    
    public func tableView(_ tableView: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        indexPaths.forEach {
            cancelTask($0)
        }
    }
    
    private func cancelTask(_ indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
        tasks[indexPath] = nil
    }
}

