//
//  FeedImageCellPresenterTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest
import EssentialFeed


struct FeedImageUIModel<Image> {
    var description: String?
    var location: String?
    var isLocationHidden: Bool
    var isLoading: Bool
    var image: Image?
    var isRetryVisible: Bool
}

protocol FeedImageView {
    associatedtype Image
    func display(model: FeedImageUIModel<Image>)
}

class FeedImageCellPresenter<View: FeedImageView, Image> where View.Image == Image {
    
    private let view: View
    private let transformer: (Data) -> Image?
    
    
    init(view: View, transformer: @escaping (Data) -> Image?) {
        self.view = view
        self.transformer = transformer
    }
    
    func didStartLoading(for model: FeedImage) {
        view.display(model: FeedImageUIModel(description: model.description,
                                             location: model.location,
                                             isLocationHidden: model.location == nil,
                                             isLoading: true,
                                             image: nil,
                                             isRetryVisible: false))
    }
    
    
    func didCompleteLoading(data: Data, for model: FeedImage) {
        guard let image = transformer(data) else {
            view.display(model: FeedImageUIModel(description: model.description,
                                                 location: model.location,
                                                 isLocationHidden: model.location == nil,
                                                 isLoading: false,
                                                 image: nil,
                                                 isRetryVisible: true))
            return
        }
        
        view.display(model: FeedImageUIModel(description: model.description,
                                             location: model.location,
                                             isLocationHidden: model.location == nil,
                                             isLoading: false,
                                             image: image,
                                             isRetryVisible: false))
    }
}

class FeedImageCellPresenterTests: XCTestCase {
    
    func test_init_doesNotHaveSideEffects() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.imageViewModels.isEmpty)
    }
    
    func test_didStartLoading_setDataAsPerFeedImage() {
        let (sut, view) = makeSUT()
        let image = uniqueFeedImage()
        sut.didStartLoading(for: image)
        
        let receivedModel = view.imageViewModels.last!
        
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
    
    private func makeSUT() -> (FeedImageCellPresenter<ViewSpy, String>, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImageCellPresenter<ViewSpy, String>(view: view, transformer: { data in String(data: data, encoding: .utf8) })
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(view)
        
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageView {
        typealias Image = String
        
        var imageViewModels: [FeedImageUIModel<String>] = []
        
        func display(model: FeedImageUIModel<String>) {
            imageViewModels.append(model)
        }
    }
}


