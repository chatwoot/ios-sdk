//
//  ChatwootController.swift
//  Chatwoot
//
//  Created by shams on 28/05/22.
//

import Foundation
import UIKit

public class ChatwootController {
    
    public init() {}

    public func startAConversationWithContact(email: String, name: String, avatar_url:String, custom_attributes: Dictionary<String, String>!) -> UIViewController {
        registerCustomFonts()
        //displaying the initial chat screen.
        let storyboardName = "Main"
        let storyboardBundle = Bundle(for: ChatwootController.self)
        let storyboardChatwoot: UIStoryboard = UIStoryboard(name: storyboardName, bundle: storyboardBundle)
        let chatwootVC = storyboardChatwoot.instantiateViewController(withIdentifier: "ChatwootNavigation")
        return chatwootVC
    }
    
    func registerCustomFonts() {
        let frameworkBundle = Bundle(for: ChatwootController.self)
        let fonts = frameworkBundle.urls(forResourcesWithExtension: "TTF", subdirectory: nil)
        fonts?.forEach({ url in
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        })
    }
}
