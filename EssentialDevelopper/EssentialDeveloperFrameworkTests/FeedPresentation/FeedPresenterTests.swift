//
//  FeedPresenterTests.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/17/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import XCTest

class FeedPresenter {
    let view: Any
    
    init(view: Any) {
        self.view = view
    }
}

class FeedPresenterTests: XCTestCase {
        
    func test_init_doesNotDoAnything() {
        let (_, view) = makeSUT()
        
        XCTAssertTrue(view.messages.isEmpty)
    }
    
    private class ViewSpy {
        var messages: [AnyObject] = []
    }
    
    private func makeSUT() -> (FeedPresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedPresenter(view: view)
        
        trackMemoryLeaks(sut)
        trackMemoryLeaks(view)
        
        return (sut, view)
    }
}
