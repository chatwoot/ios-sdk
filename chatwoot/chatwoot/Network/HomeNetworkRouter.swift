//
//  HomeNetworkRouter.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation

enum HomeNetworkRouter: Router {
    case listAllConversations
    case createContact(params: CreateContactRequest)
    case listAllMessages

    var asURL: URL {
        baseURL.appendingPathComponent(path)
    }
    
    var path: String {
        switch self {
        case .listAllConversations: return "contacts/".appending("{contact_identifier}/conversations".prepareContactIdentifier())
        case .createContact: return "contacts"
        case .listAllMessages: return "contacts/".appending("{contact_identifier}/conversations".prepareContactIdentifier().appending("/2269/messages"))
        }
        //FIXME:- append conversation id 2269 dynamically
    }
    
    var method: String {
        switch self {
        case .listAllConversations: return "GET"
        case .createContact: return "POST"
        case .listAllMessages: return "GET"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = baseURL.appendingPathComponent(path).absoluteString.removingPercentEncoding
        var request = URLRequest(url: URL (string: url!)!)
        request.httpMethod = method
        request.cachePolicy = .useProtocolCachePolicy
        
        switch self {
        case .listAllConversations:
            break
        case .listAllMessages:
            break
        case .createContact(let createContactRequest):
            request = try AFHelper.jsonEncode(createContactRequest, into: request)
        }
        return request
    }
    
  
}
