import Foundation
import Combine

@MainActor
public final class ChatwootClient: ObservableObject {
    public let configuration: ChatwootConfiguration
    @Published public private(set) var conversations: [ChatwootConversation] = []
    @Published public private(set) var title = "Support"
    @Published public private(set) var color = "#2781f6"
    @Published public private(set) var connected = false
    @Published public private(set) var revision = 0
    @Published public private(set) var pendingConversationID: Int?
    @Published public private(set) var unreadCount = 0
    @Published public private(set) var connectionError: String?
    @Published public private(set) var sessionVersion = 0
    private var connectionTask: Task<Void, Error>?
    public private(set) var allowRepliesAfterResolved = true
    public private(set) var hideBranding = false
    @Published public private(set) var preChatOptions: PreChatOptions?
    @Published public private(set) var replyTimeText: String?
    public private(set) var enabledFeatures: [String] = []
    @Published public private(set) var agentLastSeen: [Int: Double] = [:]
    private var knownContact: ConfigResponse.Contact?
    private var session: CustomerSession?
    private var pubsubToken: String?
    private var socket: URLSessionWebSocketTask?
    private var listener: Task<Void, Never>?
    private var conversationPage = 0
    private var started = false
    @Published public private(set) var hasMoreConversations = true
    private let decoder: JSONDecoder = { let d = JSONDecoder(); d.keyDecodingStrategy = .convertFromSnakeCase; return d }()
    private var key: String { configuration.baseURL.absoluteString + "|" + configuration.sdkAppID }

    public init(configuration: ChatwootConfiguration) { self.configuration = configuration }

    func request(_ path: String, method: String = "GET", query: [URLQueryItem] = [], body: [String: Any]? = nil, upload: (Data, String, String)? = nil) async throws -> Data {
        let version = sessionVersion
        var components = URLComponents(url: configuration.baseURL.appendingPathComponent("api/v1/widget/" + path), resolvingAgainstBaseURL: false)!
        components.queryItems = [URLQueryItem(name: "sdk_app_id", value: configuration.sdkAppID)] + query
        var request = URLRequest(url: components.url!)
        request.httpMethod = method; request.timeoutInterval = 30
        request.setValue(session?.token, forHTTPHeaderField: "X-Auth-Token")
        if let (bytes, name, mime) = upload {
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let safeName = name.replacingOccurrences(of: "\"", with: "").replacingOccurrences(of: "\r", with: "").replacingOccurrences(of: "\n", with: "")
            var data = Data("--\(boundary)\r\nContent-Disposition: form-data; name=\"message[attachments][]\"; filename=\"\(safeName)\"\r\nContent-Type: \(mime)\r\n\r\n".utf8)
            data.append(bytes); data.append(Data("\r\n--\(boundary)--\r\n".utf8)); request.httpBody = data
        } else if let body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        guard version == sessionVersion else { throw CancellationError() }
        guard let http = response as? HTTPURLResponse else { throw ChatwootError.message("Invalid server response.") }
        guard (200..<300).contains(http.statusCode) else {
            let json = (try? JSONSerialization.jsonObject(with: data)) as? [String: Any]
            throw ChatwootError.message(json?["error"] as? String ?? "Request failed (\(http.statusCode)). Please try again.")
        }
        return data
    }

    public func connect() async throws {
        if connected { return }
        if let connectionTask { return try await connectionTask.value }
        let task = Task { try await self.connectSession() }
        connectionTask = task
        defer { connectionTask = nil }
        try await task.value
    }
    private func connectSession() async throws {
        session = try SessionStore.load(key)
        let data = try await request("config", method: "POST", body: [:])
        let config = try decoder.decode(ConfigResponse.self, from: data)
        session = CustomerSession(token: config.websiteChannelConfig.authToken, deviceID: session?.deviceID)
        try SessionStore.save(session, key: key)
        title = config.websiteChannelConfig.websiteName
        color = configuration.accentColor ?? config.websiteChannelConfig.widgetColor
        allowRepliesAfterResolved = config.websiteChannelConfig.allowMessagesAfterResolved
        hideBranding = config.websiteChannelConfig.disableBranding
        pubsubToken = config.contact.pubsubToken
        knownContact = config.contact
        preChatOptions = config.websiteChannelConfig.preChatFormEnabled ? config.websiteChannelConfig.preChatFormOptions : nil
        enabledFeatures = config.websiteChannelConfig.enabledFeatures ?? []
        replyTimeText = ["in_a_few_minutes": "Typically replies in a few minutes", "in_a_few_hours": "Typically replies in a few hours", "in_a_day": "Typically replies in a day"][config.websiteChannelConfig.replyTime ?? ""]
        try await refreshConversations()
        connected = true
        resume()
    }

    public func refreshConversations(loadMore: Bool = false) async throws {
        if loadMore && !hasMoreConversations { return }
        let page = loadMore ? conversationPage + 1 : 1
        let data = try await request("conversations/list", query: [.init(name: "page", value: String(page))])
        struct ConversationList: Decodable {
            let payload: [ChatwootConversation]
            let meta: Meta
            struct Meta: Decodable { let hasNextPage: Bool; let unreadCount: Int }
        }
        let list = try decoder.decode(ConversationList.self, from: data)
        if loadMore { conversations += list.payload.filter { item in !conversations.contains(where: { $0.id == item.id }) } }
        else { conversations = list.payload }
        conversationPage = page
        hasMoreConversations = list.meta.hasNextPage
        unreadCount = list.meta.unreadCount
    }
    public func messages(conversationID: Int, before: Int? = nil) async throws -> [ChatwootMessage] {
        var query = [URLQueryItem(name: "conversation_id", value: String(conversationID))]
        if let before { query.append(URLQueryItem(name: "before", value: String(before))) }
        struct Messages: Decodable {
            struct Meta: Decodable { let agentLastSeenAt: Double? }
            let payload: [ChatwootMessage]
            let meta: Meta?
        }
        let result = try decoder.decode(Messages.self, from: await request("messages", query: query))
        if let seen = result.meta?.agentLastSeenAt { agentLastSeen[conversationID] = seen }
        return result.payload.sorted { $0.id < $1.id }
    }
    var preChatFields: [PreChatField] {
        (preChatOptions?.preChatFields ?? []).filter { field in
            guard field.enabled else { return false }
            if field.name == "emailAddress", knownContact?.email?.isEmpty == false { return false }
            if field.name == "phoneNumber", knownContact?.phoneNumber?.isEmpty == false { return false }
            if field.name == "fullName", knownContact?.identifier?.isEmpty == false || knownContact?.email?.isEmpty == false || knownContact?.phoneNumber?.isEmpty == false { return false }
            return true
        }
    }
    public func startConversation(message: String, preChatValues: [String: String]) async throws -> Int {
        try await connect()
        let body = try PreChatSubmission.payload(fields: preChatFields, values: preChatValues, message: message)
        let data = try await request("conversations", method: "POST", body: body)
        struct Created: Decodable { let id: Int }
        let id = try decoder.decode(Created.self, from: data).id
        // Refresh the contact details so subsequent forms can omit known standard fields.
        if let data = try? await request("config", method: "POST", body: [:]), let config = try? decoder.decode(ConfigResponse.self, from: data) { knownContact = config.contact }
        try? await refreshConversations()
        return id
    }
    public func send(_ content: String, conversationID: Int?) async throws -> Int {
        try await connect()
        if conversationID == nil, preChatOptions != nil { return try await startConversation(message: content, preChatValues: [:]) }
        let message: [String: Any] = ["content": content, "timestamp": Int(Date().timeIntervalSince1970)]
        if let conversationID {
            _ = try await request("messages", method: "POST", query: [.init(name: "conversation_id", value: String(conversationID))], body: ["message": message])
            return conversationID
        }
        let data = try await request("conversations", method: "POST", body: ["message": message])
        struct Created: Decodable { let id: Int }
        return try decoder.decode(Created.self, from: data).id
    }
    public func upload(_ data: Data, filename: String, mimeType: String, conversationID: Int) async throws {
        _ = try await request("messages", method: "POST", query: [.init(name: "conversation_id", value: String(conversationID))], upload: (data, filename, mimeType))
    }
    public func submitEmail(_ email: String, messageID: Int) async throws {
        try await connect()
        _ = try await request("messages/\(messageID)", method: "PATCH", body: ["contact": ["email": email]])
    }
    public func markRead(_ id: Int) async throws {
        _ = try await request("conversations/update_last_seen", method: "POST", query: [.init(name: "conversation_id", value: String(id))], body: [:])
        try await refreshConversations()
    }
    public func identify(identifier: String, signature: String, name: String, email: String? = nil) async throws {
        guard !identifier.isEmpty, !signature.isEmpty else { throw ChatwootError.message("A customer identifier and backend-generated signature are required.") }
        try await connect()
        if let id = session?.deviceID {
            _ = try await request("mobile_push_devices/\(id)", method: "DELETE")
            session?.deviceID = nil
            try SessionStore.save(session, key: key)
        }
        var body = ["identifier": identifier, "identifier_hash": signature, "name": name]
        if let email { body["email"] = email }
        let data = try await request("contact/set_user", method: "PATCH", body: body)
        struct Identity: Decodable { let widgetAuthToken: String? }
        if let token = try decoder.decode(Identity.self, from: data).widgetAuthToken { session?.token = token }
        try SessionStore.save(session, key: key)
        pause(); sessionVersion += 1; connected = false; conversations = []; pendingConversationID = nil
        try await connect()
        revision += 1
    }
    public func registerDeviceToken(_ token: Data, environment: String, name: String) async throws {
        try await connect()
        var body: [String: Any] = ["platform": "ios", "device_token": token.map { String(format: "%02x", $0) }.joined(), "environment": environment, "name": name]
        if let id = session?.deviceID { body["device_id"] = id }
        let data = try await request("mobile_push_devices", method: "POST", body: body)
        struct Device: Decodable { let id: Int }
        session?.deviceID = try decoder.decode(Device.self, from: data).id
        try SessionStore.save(session, key: key)
    }
    @discardableResult public func handleNotification(_ userInfo: [AnyHashable: Any]) async throws -> Bool {
        guard let payload = userInfo["chatwoot"] as? [String: Any], let id = payload["conversation_id"] as? Int, let inbox = payload["inbox_id"] as? Int else { return false }
        try await connect()
        // Verify ownership and inbox before exposing or navigating to this conversation.
        let data = try await request("conversations", query: [.init(name: "conversation_id", value: String(id))])
        struct NotificationConversation: Decodable { let inboxId: Int }
        let conversation = try decoder.decode(NotificationConversation.self, from: data)
        guard conversation.inboxId == inbox else { return false }
        pendingConversationID = id
        return true
    }
    public func consumeNotification() { pendingConversationID = nil }
    public func reset() async throws {
        // A host can sign out immediately after launch, before connect() has loaded Keychain.
        if session == nil { session = try SessionStore.load(key) }
        if let id = session?.deviceID { _ = try await request("mobile_push_devices/\(id)", method: "DELETE") }
        try SessionStore.save(nil, key: key)
        pause(); sessionVersion += 1; connectionTask?.cancel(); connectionTask = nil; session = nil; conversations = []; conversationPage = 0; connected = false; unreadCount = 0; pendingConversationID = nil
        revision += 1
    }
    public func pause() { started = false; listener?.cancel(); listener = nil; socket?.cancel(with: .goingAway, reason: nil); socket = nil }
    public func resume() {
        guard connected, !started, let pubsubToken else { return }
        started = true
        listener = Task { [weak self] in
            while !Task.isCancelled {
                guard let self else { return }
                do {
                    var url = URLComponents(url: self.configuration.baseURL.appendingPathComponent("cable"), resolvingAgainstBaseURL: false)!
                    url.scheme = url.scheme == "https" ? "wss" : "ws"
                    let socket = URLSession.shared.webSocketTask(with: url.url!)
                    self.socket = socket; socket.resume()
                    let identifier = String(data: try JSONSerialization.data(withJSONObject: ["channel": "RoomChannel", "pubsub_token": pubsubToken]), encoding: .utf8)!
                    let subscription = try JSONSerialization.data(withJSONObject: ["command": "subscribe", "identifier": identifier])
                    try await socket.send(.string(String(decoding: subscription, as: UTF8.self)))
                    try await self.refreshConversations(); self.revision += 1; self.connectionError = nil
                    while !Task.isCancelled {
                        let packet = try await socket.receive()
                        let bytes: Data
                        switch packet { case .data(let d): bytes = d; case .string(let s): bytes = Data(s.utf8); @unknown default: continue }
                        let json = (try? JSONSerialization.jsonObject(with: bytes)) as? [String: Any]
                        if let event = json?["message"] as? [String: Any], let name = event["event"] as? String, ["message.created", "message.updated", "conversation.status_changed"].contains(name) {
                            self.revision += 1
                            try await self.refreshConversations()
                        }
                    }
                } catch {
                    if Task.isCancelled { return }
                    self.socket?.cancel(with: .goingAway, reason: nil)
                    self.connectionError = "Connection interrupted. Reconnecting…"
                    try? await Task.sleep(for: .seconds(3))
                }
            }
        }
    }
}
