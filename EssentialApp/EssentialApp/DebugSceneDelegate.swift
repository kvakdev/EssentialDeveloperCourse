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
    
    override func makeHTTPClient() -> HTTPClient {
        guard let value = UserDefaults.standard.string(forKey: "connectivity") else {
            return super.makeHTTPClient()
        }
        let connectivity = value == "online"
        
        return DebugHTTPClient(connectivity: connectivity)
    }
}
#endif
