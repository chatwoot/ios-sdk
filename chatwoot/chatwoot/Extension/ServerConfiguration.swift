//
//  ServerConfiguration.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation

struct ServerConfig {
    private enum ReleaseMode {
        case develop, staging, production
    }
    
    private static let releaseMode: ReleaseMode = .production
    
    public var baseURL: URL {
        switch Self.releaseMode {
        case .develop:
            return Constants.Urls.BaseUrl.develop
        case .staging:
            return Constants.Urls.BaseUrl.staging
        case .production:
            return Constants.Urls.BaseUrl.production
        }
    }
}
