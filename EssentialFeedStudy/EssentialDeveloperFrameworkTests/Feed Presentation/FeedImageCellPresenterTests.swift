//
//  FeedImageCellPresenterTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed


class FeedImageCellPresenterTests: XCTestCase {
    
    func test_init_doesNotHaveSideEffects() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.imageViewModels.isEmpty)
    }
    
    func test_didStartLoading_setDataAsPerFeedImage() {
        let (sut, view) = makeSUT()
        let image = uniqueFeedImage()
        
        sut.didStartLoading(for: image)
        
        expect(view: view,
               for: image,
               isLoading: true,
               isRetry: false,
               imageData: nil)
    }
    
    func test_didCompleteLoadingWithData_hideLoadingAndRetry() {
        let (sut, view) = makeSUT()
        let image = uniqueFeedImage()
        let dummyImageData = "Test"
        
        sut.didCompleteLoading(data: dummyImageData.data(using: .utf8)!, for: image)
        
        expect(view: view,
               for: image,
               isLoading: false,
               isRetry: false,
               imageData: dummyImageData)
    }
    
    func test_corruptData_hidesLoadingAndShowsRetry() {
        let (sut, view) = makeSUT()
        let image = uniqueFeedImage()
        let corruptedData = "SomeString".data(using: .unicode)!
        
        sut.didCompleteLoading(data: corruptedData,
                               for: image)
        
        expect(view: view,
               for: image,
               isLoading: false,
               isRetry: true,
               imageData: nil)
    }
    
    func test_failedLoad_hidesLoaderAndShowRetryButton() {
        let (sut, view) = makeSUT()
        let image = uniqueFeedImage()

        sut.didFailLoading(error: anyNSError(), for: image)
        
        expect(view: view,
               for: image,
               isLoading: false,
               isRetry: true,
               imageData: nil)
    }
    
    private func expect(view: ViewSpy, for image: FeedImage, isLoading: Bool, isRetry: Bool, imageData: String?, file: StaticString = #file, line: UInt = #line) {
        let receivedModel = view.imageViewModels.last!
        XCTAssertEqual(view.imageViewModels.count, 1, file: file, line: line)
        XCTAssertEqual(receivedModel.description, image.description, file: file, line: line)
        XCTAssertEqual(receivedModel.location, image.location, file: file, line: line)
        XCTAssertEqual(receivedModel.isLocationHidden, image.location == nil, file: file, line: line)
        XCTAssertEqual(receivedModel.isLoading, isLoading, file: file, line: line)
        XCTAssertEqual(receivedModel.isRetryVisible, isRetry, file: file, line: line)
        XCTAssertEqual(receivedModel.image, imageData, file: file, line: line)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedImageCellPresenter<ViewSpy, String>, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImageCellPresenter<ViewSpy, String>(view: view, transformer: { data in String(data: data, encoding: .utf8) })
        
        trackMemoryLeaks(sut, file: file, line: line)
        trackMemoryLeaks(view, file: file, line: line)
        
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        typealias Image = String
        
        var imageViewModels: [FeedImageViewModel<String>] = []
        
        func display(model: FeedImageViewModel<String>) {
            imageViewModels.append(model)
        }
    }
}


