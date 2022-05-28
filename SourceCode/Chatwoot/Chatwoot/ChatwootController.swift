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
        let storyboardChatwoot = UIStoryboard(name: "Main", bundle: Bundle.messageKitAssetBundle)
        let chatwootVC = storyboardChatwoot.instantiateViewController(withIdentifier: "ChatwootNavigation")
        return chatwootVC
    }
    
    func registerCustomFonts() {
        let fonts = Bundle.messageKitAssetBundle.urls(forResourcesWithExtension: "TTF", subdirectory: nil)
        fonts?.forEach({ url in
            CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        })
    }
}
