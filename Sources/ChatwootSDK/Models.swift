import Foundation

public struct ChatwootConfiguration {
    public let baseURL: URL
    public let sdkAppID: String
    public var accentColor: String?
    public var outgoingMessageColor: String?
    public init(baseURL: URL, sdkAppID: String) {
        self.baseURL = baseURL
        self.sdkAppID = sdkAppID
    }
}

public struct ChatwootConversation: Decodable, Identifiable {
    public let id: Int
    public let cursor: Int?
    public let inboxId: Int
    public let status: String
    public let unreadCount: Int?
    public let updatedAt: Double?
    public let lastMessage: ChatwootMessage?
}
public struct ChatwootMessage: Decodable, Identifiable {
    public let id: Int
    public let content: String?
    public let messageType: Int
    public let contentType: String?
    public let createdAt: Double
    public let conversationId: Int?
    public let sender: Sender?
    public let attachments: [Attachment]?
    public let contentAttributes: ContentAttributes?
    public struct ContentAttributes: Decodable { public let submittedEmail: String? }
    public struct Sender: Decodable {
        public let name: String?
        public let avatarUrl: String?
        public let thumbnail: String?
    }
    public struct Attachment: Decodable, Identifiable {
        public let id: Int
        public let fileType: String?
        public let dataUrl: String
    }
}
struct CustomerSession: Codable {
    var token: String
    var deviceID: Int?
}
struct ConfigResponse: Decodable {
    let websiteChannelConfig: Channel
    let contact: Contact
    struct Channel: Decodable {
        let authToken: String
        let websiteName: String
        let widgetColor: String
        let allowMessagesAfterResolved: Bool
        let disableBranding: Bool
        let preChatFormEnabled: Bool
        let preChatFormOptions: PreChatOptions?
        let replyTime: String?
        let enabledFeatures: [String]?
    }
    struct Contact: Decodable { let pubsubToken: String; let name: String?; let email: String?; let phoneNumber: String?; let identifier: String? }
}
struct Page<T: Decodable>: Decodable { let payload: [T] }
public enum ChatwootError: LocalizedError {
    case message(String)
    public var errorDescription: String? { if case .message(let text) = self { return text }; return nil }
}
