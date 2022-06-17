//
//  FeedPresenterTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest

struct FeedLoaderUIModel {
    let isLoading: Bool
    let errorMessage: String?
    
    static var loading: FeedLoaderUIModel {
        FeedLoaderUIModel(isLoading: true, errorMessage: nil)
    }
}

protocol LoaderView {
    func display(uiModel: FeedLoaderUIModel)
}

class FeedPresenter {
    let loaderView: LoaderView
    
    init(loaderView: LoaderView) {
        self.loaderView = loaderView
    }
    
    func didStartLoadingFeed() {
        self.loaderView.display(uiModel: .loading)
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
        
        XCTAssertEqual(view.messages, [.display(isLoading: true)])
    }
    
    private class ViewSpy: LoaderView {
        func display(uiModel: FeedLoaderUIModel) {
            messages.append(.display(isLoading: true))
        }
        
        enum Messages: Equatable {
            case display(isLoading: Bool)
        }
        
        var messages: [Messages] = []
    }
    
    private func makeSUT() -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(loaderView: view)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(view)
        
        return (sut, view)
    }
}
