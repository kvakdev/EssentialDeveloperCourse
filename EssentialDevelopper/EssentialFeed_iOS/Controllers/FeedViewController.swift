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

class FeedImageCellController {
    var task: FeedImageDataLoaderTask?
    let model: FeedImage
    let imageLoader: FeedImageLoader
    
    init(model: FeedImage, imageLoader: FeedImageLoader) {
        self.imageLoader = imageLoader
        self.model = model
    }
    
    func makeView() -> FeedImageCell {
        let cell = FeedImageCell()
        
        cell.retryButton.isHidden = true
        cell.feedImageView.image = nil
        cell.locationContainer.isHidden = model.location == nil
        cell.descriptionLabel.text = model.description
        cell.locationLabel.text = model.location
        cell.imageContainer.startShimmering()
        
        let loadImage: () -> Void = { [weak self] in
            guard let self = self else { return }
            
            self.task = self.imageLoader.loadImage(with: self.model.url) { result in
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
    
    func cancelTask() {
        task?.cancel()
        task = nil
    }
}

public final class FeedViewController: UITableViewController, UITableViewDataSourcePrefetching {
    private var refreshController: RefreshController?
    var tableModel: [FeedImageCellController] = [] {
        didSet { tableView.reloadData() }
    }
    
    public convenience init(loader: FeedLoader, imageLoader: FeedImageLoader) {
        self.init()
        self.refreshController = RefreshController(loader: loader, onRefresh: { [weak self] feed in
            self?.tableModel = feed.map {
                FeedImageCellController(model: $0, imageLoader: imageLoader)
            }
        })
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

