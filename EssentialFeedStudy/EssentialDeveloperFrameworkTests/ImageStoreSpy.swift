//
//  ImageStoreSpy.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation
import EssentialFeed

class ImageStoreSpy: ImageStore {
    private class RetreiveTaskSpy: CancellableTask {
        private let cancelClosure: VoidClosure
        
        init(cancelClosure: @escaping VoidClosure) {
            self.cancelClosure = cancelClosure
        }
        
        func cancel() {
            self.cancelClosure()
        }
    }
    
    enum Message: Equatable {
        case retreive(url: URL)
        case insert(url: URL, data: Data)
    }
    
    var retreiveCompletions: [Closure<ImageStore.RetrieveResult>] = []
    var insertCompletions: [Closure<ImageStore.InsertResult>] = []
    var messages: [Message] = []
    
    var cancelledURLs: [URL] = []
    var requestedURLs: [URL] = []
    
    @discardableResult
    func retrieveImageData(from url: URL, completion: @escaping (Result<Data?, Error>) -> Void) -> CancellableTask {
        messages.append(.retreive(url: url))
        retreiveCompletions.append(completion)
        
        return RetreiveTaskSpy(cancelClosure: { [weak self] in self?.cancelledURLs.append(url) })
    }
    
    func insert(image data: Data, for url: URL, completion: @escaping (InsertResult) -> Void) {
        messages.append(.insert(url: url, data: data))
        insertCompletions.append(completion)
    }
    
    func complete(with error: Error, at index: Int = 0) {
        self.retreiveCompletions[index](.failure(error))
    }
    
    func complete(with data: Data? = nil, at index: Int = 0) {
        self.retreiveCompletions[index](.success(data))
    }
    
    func insertComplete(with error: Error, at index: Int = 0) {
        self.insertCompletions[index](.failure(error))
    }
    
    func insertCompleteWithSuccess(at index: Int = 0) {
        self.insertCompletions[index](.success(()))
    }
}
