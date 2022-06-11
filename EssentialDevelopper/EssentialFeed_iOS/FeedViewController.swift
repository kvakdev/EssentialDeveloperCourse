//
//  FeedViewController.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/10/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import UIKit
import EssentialFeed

public class FeedImageCell: UITableViewCell {
    public var locationLabel = UILabel()
    public var descriptionLabel = UILabel()
    public var locationContainer = UIView()
}

public protocol FeedImageDataLoaderTask {
    func cancel()
}

public protocol FeedImageLoader {
    func loadImage(with url: URL) -> FeedImageDataLoaderTask
}

public class FeedViewController: UITableViewController {
    private var loader: FeedLoader?
    private var imageLoader: FeedImageLoader?
    private var tasks: [IndexPath: FeedImageDataLoaderTask] = [:]
    
    public var tableModel: [FeedImage] = []
    
    public convenience init(loader: FeedLoader, imageLoader: FeedImageLoader) {
        self.init()
        self.loader = loader
        self.imageLoader = imageLoader
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setupRefresh()
        load()
    }
    
    func setupRefresh() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(load), for: .valueChanged)
    }
    
    @objc
    func load() {
        self.refreshControl?.beginRefreshing()
        
        self.loader?.load() { [weak self] result in
            if let feed = try? result.get() {
                self?.tableModel = feed
                self?.tableView.reloadData()
            }
            self?.refreshControl?.endRefreshing()
        }
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableModel.count
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = FeedImageCell()
        let cellModel = tableModel[indexPath.row]
        
        cell.locationContainer.isHidden = cellModel.location == nil
        cell.descriptionLabel.text = cellModel.description
        cell.locationLabel.text = cellModel.location
        tasks[indexPath] = imageLoader?.loadImage(with: cellModel.url)
        
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tasks[indexPath]?.cancel()
    }
}

