//
//  FeedPresenterTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed

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
    
    func test_failedLoading_displaysError() {
        let (sut, view) = makeSUT()
        sut.didCompleteLoadingWith(error: anyNSError())
        
        XCTAssertEqual(view.messages, [
            .display(isLoading: false),
            .display(error: localized("FEED_LOADING_ERROR"))])
    }
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("FEED_TITLE_VIEW"))
    }
    
    private func localized(_ key: String, bundle: Bundle = Bundle(for: FeedPresenter.self), in table: String = "Feed", comment: String = "") -> String {
        let value = NSLocalizedString(key,
                                      tableName: table,
                                      bundle: bundle,
                                      value: "",
                                      comment: comment)
        if value == key {
            XCTFail("Missing value for key \(key)")
        }
        
        return value
    }
    
    private let localizedError: String =
        NSLocalizedString("FEED_LOADING_ERROR",
                          tableName: "Feed",
                          bundle: Bundle(for: FeedPresenter.self),
                          value: "",
                          comment: "error after feed loading")
    
    private class ViewSpy: LoaderView, FeedView, ErrorView {
        
        enum Messages: Equatable {
            case display(isLoading: Bool)
            case display(error: String?)
            case display(feed: [FeedImage])
        }
        var messages: [Messages] = []
        
        func display(uiModel: FeedLoaderViewModel) {
            messages.append(.display(isLoading: uiModel.isLoading))
        }
        
        func display(model: FeedViewModel) {
            messages.append(.display(feed: model.feed))
        }
        
        func display(model: FeedErrorViewModel) {
            messages.append(.display(error: model.message))
        }
    }
    
    private func makeSUT() -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view, loaderView: view, errorView: view)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(view)
        
        return (sut, view)
    }
}
