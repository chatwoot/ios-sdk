//
//  CreateContactModel.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation

// MARK: - CreateContactRequest
struct CreateContactRequest: Encodable {
    let identifier: String!
    let identifier_hash: String!
    let email: String!
    let name: String!
    let avatar_url: String!
    let custom_attributes: Dictionary<String, String>!
}

// MARK: - CreateContactModel
struct CreateContactModel: Codable {
    let contactID: Int!
    let sourceID: String!
    let contactName: String!
    let contactEmail: String!
    let pubsubToken: String!
    
    enum CodingKeys: String, CodingKey {
        case contactID = "id"
        case sourceID = "source_id"
        case contactName = "name"
        case contactEmail = "email"
        case pubsubToken = "pubsub_token"
    }
}
