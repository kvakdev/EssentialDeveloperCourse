//
//  FeedUIComposer.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/12/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed
import UIKit

public class FeedUIComposer {
    private init() {}
    
    public static func makeFeedViewController(loader: FeedLoader, imageLoader: FeedImageLoader) -> FeedViewController {
        
        let presentationAdapter = FeedPresentationAdapter(loader: loader)
        let bundle = Bundle(for: FeedViewController.self)
        let feedViewController = UIStoryboard(name: "Feed", bundle: bundle).instantiateInitialViewController() as! FeedViewController
     
        feedViewController.delegate = presentationAdapter
        
        let adapter = FeedViewAdapter(feedViewController: feedViewController, imageLoader: imageLoader)
        let presenter = FeedPresenter(view: adapter, loaderView: VirtualWeakRefProxy(feedViewController))
        
        presentationAdapter.delegate = presenter
        
        return feedViewController
    }
}

class FeedPresentationAdapter: FeedViewControllerDelegate {
    let loader: FeedLoader
    var delegate: FeedLoadDelegate?
    
    init(loader: FeedLoader) {
        self.loader = loader
    }
    
    func didRequestFeedLoad() {
        delegate?.didStartLoadingFeed()

        loader.load { [weak self] result in
            switch result {
            case .success(let feed):
                self?.delegate?.didCompleteLoading(with: feed)
            case .failure(let error):
                self?.delegate?.didCompleteLoadingWith(error: error)
            }
        }
    }
}

class FeedViewAdapter: FeedView {
    weak var feedViewController: FeedViewController?
    let imageLoader: FeedImageLoader
    
    func display(model: FeedUIModel) {
        feedViewController?.tableModel = model.feed.map {
            let feedImageAdapter = FeedImageCompositionAdapter<VirtualWeakRefProxy<FeedImageCellController>, UIImage>(imageLoader: imageLoader, model: $0)
            let controller = FeedImageCellController(delegate: feedImageAdapter)
            let view = VirtualWeakRefProxy(controller)
            let presenter = FeedImageCellPresenter(view: view, transformer: UIImage.init)
            
            feedImageAdapter.presenter = presenter
            
            return controller
        }
    }

    init(feedViewController: FeedViewController, imageLoader: FeedImageLoader) {
        self.feedViewController = feedViewController
        self.imageLoader = imageLoader
    }
}

class VirtualWeakRefProxy<T: AnyObject> {
    weak var object: T?
    
    init(_ object: T) {
        self.object = object
    }
}

extension VirtualWeakRefProxy: FeedView where T: FeedView {
    func display(model: FeedUIModel) {
        object?.display(model: model)
    }
}

extension VirtualWeakRefProxy: LoaderView where T: LoaderView {
    func display(uiModel: FeedLoaderUIModel) {
        object?.display(uiModel: uiModel)
    }
}

extension VirtualWeakRefProxy: FeedImageView where T: FeedImageView {
    func display(model: FeedImageUIModel<T.Image>) {
        object?.display(model: model)
    }
}

class FeedImageCompositionAdapter<View: FeedImageView, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    
    private let imageLoader: FeedImageLoader
    private let model: FeedImage

    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImageCellPresenter<View, Image>?
    
    init(imageLoader: FeedImageLoader, model: FeedImage) {
        self.imageLoader = imageLoader
        self.model = model
    }
    
    func didRequestToLoadImage() {
        presenter?.didStartLoading(for: model)
        
        self.task = self.imageLoader.loadImage(with: self.model.url) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let data):
                self.presenter?.didCompleteLoading(data: data, for: self.model)
            case .failure(let error):
                self.presenter?.didFailLoading(error: error, for: self.model)
            }
        }
    }
    func didCancelTask() {
        task?.cancel()
        task = nil
    }
    
    deinit { didCancelTask() }
}
