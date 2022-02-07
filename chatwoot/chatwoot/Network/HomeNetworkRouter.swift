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
    case listAllMessages(conversationID: String)
    case sendTextMessage(conversationID: String, params: SendTextMessageModelRequest)

    var asURL: URL {
        baseURL.appendingPathComponent(path)
    }
    
    var path: String {
        switch self {
        case .listAllConversations:
            return "contacts/".appending(getContactIdentifier() + "/conversations")
        case .createContact:
            return "contacts"
        case .listAllMessages(let conversationID):
            return "contacts/".appending(getContactIdentifier() + "/conversations" + "/" + conversationID + "/messages")
        case .sendTextMessage(let conversationID, _):
            return "contacts/".appending(getContactIdentifier() + "/conversations" + "/" + conversationID + "/messages")
        }
    }
    
    var method: String {
        switch self {
        case .listAllConversations: return "GET"
        case .createContact: return "POST"
        case .listAllMessages(_): return "GET"
        case .sendTextMessage(_, _): return "POST"
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
        case .listAllMessages(_):
            break
        case .createContact(let createContactRequest):
            request = try AFHelper.jsonEncode(createContactRequest, into: request)
        case .sendTextMessage(_, let sendTextMessageModelRequest):
            request = try AFHelper.jsonEncode(sendTextMessageModelRequest, into: request)
        }
        return request
    }
    
    func getContactIdentifier() -> String {
        var contactIdentifier = ""
        if let contactInfo = GetUserDefaults.contactInfo {
            if let sourceID = contactInfo.sourceID {
                contactIdentifier = sourceID
            }
        }
        return contactIdentifier
    }
}
