//
//  DebugHTTPClient.swift
//  EssentialApp
//
//  Created by Andre Kvashuk on 6/25/22.
//
#if DEBUG
import Foundation
import EssentialFeed
import UIKit

class DebugHTTPClient: HTTPClient {
    private let connectivity: Bool
    init(connectivity: Bool) {
        self.connectivity = connectivity
    }
    
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        if !connectivity {
            completion(.failure(NSError(domain: "OFFLINE", code: 0)))
        } else {
            completion(.success((makeResponse(url: url), makeData(url: url))))
        }
        return AnyTask()
    }
                       
    private func makeResponse(url: URL) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
    }
    
    private func makeData(url: URL) -> Data {
        if url.absoluteString == debugImageURL() {
            return makeImageData()
        } else {
            return debugFeedData()
        }
    }
    
    private func makeImageData() -> Data {
        let size = CGSize(width: 1, height: 1)
        
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(UIColor.red.cgColor)
        context?.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!.pngData()!
    }
    
    private func debugFeedData() -> Data {
        return try! JSONSerialization.data(withJSONObject: ["items" : [
            ["id": UUID().uuidString, "image": "\(debugImageURL()))"],
            ["id": UUID().uuidString, "image": "\(debugImageURL()))"]
                    ]])
    }
    
    private func debugImageURL() -> String {
        "http://image.com"
    }
    
    private class AnyTask: HTTPClientTask {
        func cancel() {}
    }
}
#endif
