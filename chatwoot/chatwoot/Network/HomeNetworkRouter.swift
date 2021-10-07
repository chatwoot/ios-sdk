//
//  HomeNetworkRouter.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation

enum HomeNetworkRouter: Router {
    case termsAndConditions
    case switchAccount(params: SwitchAccountRequest)
    
    var asURL: URL {
        baseURL.appendingPathComponent(path)
    }
    
    var path: String {
        switch self {
        case .termsAndConditions: return "termsandconditions"
        case .switchAccount: return "auth/switch"
        }
    }
    
    var method: String {
        switch self {
        case .termsAndConditions: return "GET"
            
        case .switchAccount: return "POST"
            
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding
        var request = URLRequest(url: URL (string: url!)!)
        request.httpMethod = method
        request.cachePolicy = .useProtocolCachePolicy
        request.setAuthorizationHeader()
        
        switch self {
        case .termsAndConditions:
            break
        case .switchAccount(let switchRequest):
            request = try AFHelper.jsonEncode(switchRequest, into: request)
        }
        return request
    }
}
