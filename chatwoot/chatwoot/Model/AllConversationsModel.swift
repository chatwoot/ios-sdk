//
//  AllConversationsModel.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation

// MARK: - AllConversationsModel
struct AllConversationsModel: Codable {
    let conversationID: Int!
    let inboxID: Int!
    let messages: [MessageModel]!
    let contact: ContactModel

    enum CodingKeys: String, CodingKey {
        case conversationID = "id"
        case inboxID = "inbox_id"
        case messages = "messages"
        case contact = "contact"
    }
}

struct MessageModel: Codable {
    let messageID: Int!
    let content: String!
    let messageType: Int!
    let contentType: String!
    let createdAt: TimeInterval!
    let conversationID: Int!
    let sender: SenderModel!
    
    enum CodingKeys: String, CodingKey {
        case messageID = "id"
        case content = "content"
        case messageType = "message_type"
        case contentType = "content_type"
        case createdAt = "created_at"
        case conversationID = "conversation_id"
        case sender = "sender"
    }
}

struct SenderModel: Codable {
    let senderID: Int!
    let senderName: String!
    let pubsubToken: String!
    
    enum CodingKeys: String, CodingKey {
        case senderID = "id"
        case senderName = "name"
        case pubsubToken = "pubsub_token"
    }
}

struct ContactModel: Codable {
    let contactID: Int!
    let contactName: String!
    let contactEmail: String!
    let accountID: Int!
    let pubsubToken: String!
    let lastActivityAt: String!

    enum CodingKeys: String, CodingKey {
        case contactID = "id"
        case contactName = "name"
        case contactEmail = "email"
        case accountID = "account_id"
        case pubsubToken = "pubsub_token"
        case lastActivityAt = "last_activity_at"
    }
}
