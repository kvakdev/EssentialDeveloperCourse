//
//  DebugSceneDelegate.swift
//  EssentialApp
//
//  Created by Andre Kvashuk on 6/25/22.
//

import Foundation
import UIKit
import EssentialFeed
import CoreData

#if DEBUG
class DebugSceneDelegate: SceneDelegate {
    
    override func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        if CommandLine.arguments.contains("-reset") {
            try? FileManager.default.removeItem(at: storeURL)
        }
        
        super.scene(scene, willConnectTo: session, options: connectionOptions)
    }
    
    override func makeHTTPClient(isOffline: Bool) -> HTTPClient {
        guard !isOffline else {
            return AlwaysFailingHTTPClient()
        }
        
        return super.makeHTTPClient(isOffline: isOffline)
    }
}

class AlwaysFailingHTTPClient: HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClient.Result) -> Void) -> HTTPClientTask {
        completion(.failure(NSError(domain: "OFFLINE", code: 0)))
        
        return AnyTask()
    }
    
    private class AnyTask: HTTPClientTask {
        func cancel() {}
    }
}
#endif
