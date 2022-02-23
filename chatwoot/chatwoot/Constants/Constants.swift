//
//  Constants.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//


import Foundation

enum Constants {
    static let inboxIdentifier = "STep3JLJv44qiqVBc2ueXpix"
}

extension Constants {
    
    enum Urls {
        
        enum BaseUrl {
            static let develop    = "https://develop.chatwoot.com/public/api/v1/inboxes/{inbox_identifier}/"
            static let staging    = "https://staging.chatwoot.com/public/api/v1/inboxes/{inbox_identifier}/"
            static let production = "https://chatwoot.com/public/api/v1/inboxes/{inbox_identifier}/"
        }
        
        enum ImageURl {
            static let develop    = "https://api-dev.blob.core.windows.net"
            static let staging    = "https://api-staing.blob.core.windows.net"
            static let production = "https://api-production.blob.core.windows.net"
        }
        
        enum SocketUrl {
            static let develop    = "wss://develop.chatwoot.com/cable"
            static let staging    = "wss://staging.chatwoot.com/cable"
            static let production = "wss://chatwoot.com/cable"
        }
    }
    
    enum Messages {
        static let noConversationFound = "No conversation found"
        static let noMessagesFound = "No Messages"
        static let noContentFound = "No content available"
        static let picMessage = "Picture message"
        static let audioMessage = "Audio message"
        static let fileMessage = "File message"
    }
}
