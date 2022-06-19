//
//  URLProtocol+Stub.swift
//  EssentialDeveloperFrameworkTests
//
//  Created by Andre Kvashuk on 6/19/22.
//  Copyright © 2022 Andre Kvashuk. All rights reserved.
//

import Foundation

class URLProtocolStub: URLProtocol {
    var requestedURL: URL?
    
    public static var _stub: Stub?
    public static var stub: Stub? {
        get { return queue.sync { _stub } }
        set { queue.sync { _stub = newValue } }
    }
    
    typealias ObserverRequestBlock = (URLRequest) -> Void
    
    private static let queue = DispatchQueue(label: "URLProtocolQueue")
    
    struct Stub {
        var data: Data?
        var response: URLResponse?
        var error: Error?
        var observeRequestBlock: ObserverRequestBlock?
    }
    
    public static func stub(data: Data?, response: URLResponse?, error: Error?) {
        stub = Stub(data: data, response: response, error: error)
    }
    
    static func observeRequest(completion: @escaping (URLRequest) -> ()) {
        stub = Stub(data: nil, response: nil, error: nil, observeRequestBlock: completion)
    }
    
    static func removeStub() {
        stub = nil
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        guard let stub = URLProtocolStub.stub else { return }
        
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        
        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
        stub.observeRequestBlock?(request)
    }
    
    override func stopLoading() {}
}
