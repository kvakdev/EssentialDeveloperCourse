//
//  FeedPresenterTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed

struct FeedUIModel {
    let feed: [FeedImage]
}

struct FeedLoaderUIModel {
    let isLoading: Bool
    let errorMessage: String?
    
    static var loading: FeedLoaderUIModel {
        FeedLoaderUIModel(isLoading: true, errorMessage: nil)
    }
    
    static var noError: FeedLoaderUIModel {
        FeedLoaderUIModel(isLoading: false, errorMessage: nil)
    }
}

protocol LoaderView {
    func display(uiModel: FeedLoaderUIModel)
}

protocol FeedView {
    func display(model: FeedUIModel)
}

class FeedPresenter {
    let view: FeedView
    let loaderView: LoaderView
    
    init(view: FeedView, loaderView: LoaderView) {
        self.view = view
        self.loaderView = loaderView
    }
    
    func didStartLoadingFeed() {
        self.loaderView.display(uiModel: .loading)
    }
    
    func didCompleteLoading(with feed: [FeedImage]) {
        self.view.display(model: FeedUIModel(feed: feed))
        self.loaderView.display(uiModel: .noError)
    }

}

class FeedPresenterTests: XCTestCase {
        
    func test_init_doesNotDoAnything() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    func test_didStartLoadingFeed_showLoading() {
        let (sut, view) = makeSUT()
        sut.didStartLoadingFeed()
        
        XCTAssertEqual(view.messages, [.display(isLoading: true),
            .display(error: nil)], "Expected loading and no error when loading starts.")
    }
    
    func test_completeLoading_displaysFeedAndNoError() {
        let (sut, view) = makeSUT()
        let feed = [uniqueFeedImage()]
        sut.didCompleteLoading(with: feed)
        
        XCTAssertEqual(view.messages, [
            .display(feed: feed),
            .display(isLoading: false),
            .display(error: nil)])
    }
    
    private class ViewSpy: LoaderView, FeedView {
        
        enum Messages: Equatable {
            case display(isLoading: Bool)
            case display(error: String?)
            case display(feed: [FeedImage])
        }
        var messages: [Messages] = []
        
        func display(uiModel: FeedLoaderUIModel) {
            messages.append(.display(isLoading: uiModel.isLoading))
            messages.append(.display(error: uiModel.errorMessage))
        }
        
        func display(model: FeedUIModel) {
            messages.append(.display(feed: model.feed))
        }
    }
    
    private func makeSUT() -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view, loaderView: view)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(view)
        
        return (sut, view)
    }
}
