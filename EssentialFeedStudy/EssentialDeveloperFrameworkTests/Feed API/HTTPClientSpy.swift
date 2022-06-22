//
//  HTTPClientSpy.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed

class HTTPClientSpy: HTTPClient {
    var messages = [(url: URL, completion:(HTTPClient.Result) -> ())]()
    var cancelledURLs: [URL] = []
    var requestedURLs: [URL] {
        return messages.map { $0.url }
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> ()) -> HTTPClientTask {
        messages.append((url, completion))
        
        return HTTPTask(cancelCompletion: { [weak self] in self?.cancelledURLs.append(url) })
    }
    
    func complete(with error: Error, at index: Int = 0) {
        self.messages[index].completion(.failure(error))
    }
    
    func completeWith(statusCode: Int, data: Data = Data(), at index: Int = 0) {
        let httpResponse = HTTPURLResponse(
            url: requestedURLs[index],
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil)!
        
        self.messages[index].completion(.success((httpResponse, data)))
    }
    
    func complete(with result: HTTPClient.Result, at index: Int) {
        messages[index].completion(result)
    }
}

extension HTTPClientSpy {
    private class HTTPTask: HTTPClientTask {
        var cancelCompletion: VoidClosure?
        
        init(cancelCompletion: @escaping VoidClosure) {
            self.cancelCompletion = cancelCompletion
        }
        
        func cancel() {
            cancelCompletion?()
            cancelCompletion = nil
        }
    }
}
