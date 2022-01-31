//
//  AppDelegate.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }
        
        configMessageKitTypes()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK: MessageKit configs
    func configMessageKitTypes() {
        UserDefaults.standard.set(true, forKey: "Text Messages")
        UserDefaults.standard.set(true, forKey: "AttributedText Messages")
        UserDefaults.standard.set(true, forKey: "Photo Messages")
        UserDefaults.standard.set(true, forKey: "Photo from URL Messages")
        UserDefaults.standard.set(true, forKey: "Video Messages")
        UserDefaults.standard.set(true, forKey: "Audio Messages")
        UserDefaults.standard.set(true, forKey: "Emoji Messages")
        UserDefaults.standard.set(true, forKey: "Location Messages")
        UserDefaults.standard.set(true, forKey: "Url Messages")
        UserDefaults.standard.set(true, forKey: "Phone Messages")
        UserDefaults.standard.set(true, forKey: "ShareContact Messages")
    }
}

