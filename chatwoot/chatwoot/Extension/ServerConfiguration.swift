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
    
    private static let releaseMode: ReleaseMode = .staging
    
    public var baseURL: URL {
        var urlFormatted = ""
        switch Self.releaseMode {
        case .develop:
            urlFormatted = Constants.Urls.BaseUrl.develop
        case .staging:
            urlFormatted = Constants.Urls.BaseUrl.staging
        case .production:
            urlFormatted = Constants.Urls.BaseUrl.production
        }
        return URL(string: urlFormatted.replacingOccurrences(of: "{inbox_identifier}", with: Constants.inboxIdentifier))!
    }
}
