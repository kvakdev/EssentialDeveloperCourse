//
//  FeeImageCellViewModel.swift
//  EssentialFeed_iOS
//
//  Created by Andre Kvashuk on 6/13/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed

class FeedImageCellViewModel<Image> {
    typealias Observer<T> = (T) -> Void
    var description: String? { model.description }
    var location: String? { model.location }
    var isLocationHidden: Bool { model.location == nil }
    
    private let model: FeedImage
    private let imageLoader: FeedImageLoader
    private let transformer: (Data) -> Image?
    
    var onIsLoadingStateChange: Observer<Bool>?
    var onImageLoad: Observer<Image>?
    var onRetryStateChange: Observer<Bool>?
    
    var task: FeedImageDataLoaderTask?
    
    init(model: FeedImage, imageLoader: FeedImageLoader, transformer: @escaping (Data) -> Image?) {
        self.imageLoader = imageLoader
        self.model = model
        self.transformer = transformer
    }
    
    func loadImage() {
        onIsLoadingStateChange?(true)
        
        loadImage { [weak self] result in
            self?.handle(result: result)
        }
    }
    
    private func handle(result: Result<Image, Error>) {
        switch result {
        case .success(let image):
            self.onImageLoad?(image)
            self.onRetryStateChange?(false)
        case.failure:
            self.onRetryStateChange?(true)
        }
        
        self.onIsLoadingStateChange?(false)
    }
    
    private func loadImage(completion: @escaping (Result<Image, Error>) -> Void) {
        let transform = self.transformer
        self.task = self.imageLoader.loadImage(with: self.model.url) { result in
            let data = try? result.get()
            if let image = data.map(transform) ?? nil {
                completion(.success(image))
            } else {
                completion(.failure(NSError(domain: "no image fetched", code: 0)))
            }
        }
    }
    
    func cancelTask() {
        task?.cancel()
        task = nil
    }
    
    deinit { cancelTask() }
}
