//
//  AppSession.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation

struct AppSession {
    
    static let appName: String = "chatwoot"
    
    public static var current = AppSession()
    
    private init() {
       
    }
    
    // MARK: - UserSession
    
    var userSession = UserSession()
    

    static func login(_ user: String) {
       
    }
    
    static func registered(_ user: String) {
        
        UserDefaults().setIsLoggedIn(value: false)
    }
    
    static func logout() {
        current.userSession.logout()
    }
 
}

struct UserSession {
    mutating func logout() {
        SetUserDefaults.authToken("")
        UserDefaults().setIsLoggedIn(value: false)
        SetUserDefaults.userName("")
    }
}

//User Userdefault keys
struct UserDefaultKey {
    static let authToken = "authToken"
    static let username  = "userId"
}

//Getter
struct GetUserDefaults {
    static var authToken: String {
        UserDefaults.standard.getStringValueFor(key: UserDefaultKey.authToken)
    }

    static var userName: String {
        return UserDefaults.standard.getStringValueFor(key: UserDefaultKey.username)
    }
}

//Setter
struct SetUserDefaults {
    static func authToken(_ token: String) {
        UserDefaults.standard.setStringValueFor(key: UserDefaultKey.authToken, value: token)
    }

    static func userName(_ userName: String) {
        UserDefaults.standard.setStringValueFor(key: UserDefaultKey.username, value: userName)
    }
}

extension UserDefaults {
    
    func setStringValueFor (key: String, value: String) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    func getStringValueFor (key: String) -> String {
        let value = UserDefaults.standard.string(forKey: key)
        return (value == nil) ? "" : value!
    }
    
    func setCustomObjectFor (key: String, value: Data) {
        UserDefaults.standard.set(value, forKey: key)
        UserDefaults.standard.synchronize()
    }
        
    func setIsLoggedIn(value: Bool) {
        set(value, forKey: "IsLoggedIn")
        synchronize()
    }
    
    func isLoggedIn() -> Bool {
        return bool(forKey: "IsLoggedIn")
    }
}
