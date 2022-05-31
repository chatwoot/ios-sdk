//
//  AllConversationsModel.swift
//  chatwoot
//
//  Created by shamzz on 21/09/21.
//

import Foundation

// MARK: - AllConversationsModel
struct AllConversationsModel: Codable, Equatable {
    static func == (lhs: AllConversationsModel, rhs: AllConversationsModel) -> Bool {
        return lhs.conversationID == rhs.conversationID && lhs.inboxID == rhs.inboxID
    }
    
    let conversationID: Int!
    let inboxID: Int!
    let agentLastSeenAt: TimeInterval!
    var messages: [MessageModel]!
    let contact: ContactModel

    enum CodingKeys: String, CodingKey {
        case conversationID = "id"
        case inboxID = "inbox_id"
        case agentLastSeenAt = "agent_last_seen_at"
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
    let isPrivate: Bool!
    let sender: SenderModel!
    let attachments: [AttachmentModel]!
    
    enum CodingKeys: String, CodingKey {
        case messageID = "id"
        case content = "content"
        case messageType = "message_type"
        case contentType = "content_type"
        case createdAt = "created_at"
        case conversationID = "conversation_id"
        case isPrivate = "private"
        case sender = "sender"
        case attachments = "attachments"
    }
}

struct SenderModel: Codable {
    let senderID: Int!
    let senderName: String!
    let pubsubToken: String!
    let thumbnail: String!
    
    enum CodingKeys: String, CodingKey {
        case senderID = "id"
        case senderName = "name"
        case pubsubToken = "pubsub_token"
        case thumbnail = "thumbnail"
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

struct AttachmentModel: Codable {
    let attachmentID: Int!
    let messageID: Int!
    let fileType: String!
    let accountID: Int!
    let fileExtension: String!
    let dataURL: String!
    let thumbURL: String!

    enum CodingKeys: String, CodingKey {
        case attachmentID = "id"
        case messageID = "message_id"
        case fileType = "file_type"
        case accountID = "account_id"
        case fileExtension = "extension"
        case dataURL = "data_url"
        case thumbURL = "thumb_url"
    }
}

// MARK: - FOR SOCKET MESSAGE
struct SocketMessageModel: Codable {
    let messageSocketData: MessageSocketDataModel!
    enum CodingKeys: String, CodingKey {
        case messageSocketData = "message"
    }
}

struct MessageSocketDataModel: Codable {
    let event: String!
    let message: MessageModel!
    
    enum CodingKeys: String, CodingKey {
        case event = "event"
        case message = "data"
    }
}


