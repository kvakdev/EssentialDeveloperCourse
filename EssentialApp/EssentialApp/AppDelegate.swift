//
//  AppDelegate.swift
//  EssentialApp
//
//  Created by Andre Kvashuk on 6/22/22.
//

import UIKit
import EssentialFeed
import EssentialFeed_iOS
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let configuration = UISceneConfiguration(name: "Default configuration", sessionRole: connectingSceneSession.role)
        
        #if DEBUG
        configuration.delegateClass = DebugSceneDelegate.self
        #endif
        
        return configuration
    }
}

