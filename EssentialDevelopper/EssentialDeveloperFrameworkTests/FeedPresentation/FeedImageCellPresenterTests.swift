//
//  FeedImageCellPresenterTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest

class FeedImageCellPresenter {
    let view: Any
    
    init(view: Any) {
        self.view = view
    }
}

class FeedImageCellPresenterTests: XCTestCase {
    
    func test_init_doesNotHaveSideEffects() {
        let (_, view) = makeSUT()
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    private func makeSUT() -> (FeedImageCellPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImageCellPresenter(view: view)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(view)
        
        return (sut, view)
    }
    
    private class ViewSpy {
        var messages: [Any] = []
    }
}


