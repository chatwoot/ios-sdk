//
//  Constants.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//


import Foundation
enum Constants {

}

extension Constants {
    
    enum Urls {
        
        enum BaseUrl {
            static let develop = URL(string: "https://api-dev..../")!
            static let staging = URL(string: "https://api-staing..../")!
            static let production = URL(string: "https://api-production..../")!
        }
        
        enum ImageURl {
            static let develop = "https://api-dev.blob.core.windows.net"
            static let staging = "https://api-staing.blob.core.windows.net"
            static let production = "https://api-production.blob.core.windows.net"
        }
    }
}
