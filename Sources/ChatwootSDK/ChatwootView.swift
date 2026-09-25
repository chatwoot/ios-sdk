import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

public struct ChatwootView: View {
    @ObservedObject private var client: ChatwootClient
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @State private var path: [Int] = []
    @State private var error: String?
    @State private var loading = true
    public init(client: ChatwootClient) { self.client = client }
    public var body: some View {
        NavigationStack(path: $path) {
            ScrollView {
                LazyVStack(spacing: 16) {
                    if loading { ProgressView("Loading conversations…").padding(40) }
                    if let error { ErrorNotice(text: error) { Task { await load() } } }
                    ForEach(client.conversations) { conversation in
                        Button { path.append(conversation.id) } label: { ConversationRow(conversation: conversation, title: client.title) }
                            .buttonStyle(.plain)
                    }
                    if client.hasMoreConversations && !client.conversations.isEmpty {
                        Button("Load older conversations") { Task { do { try await client.refreshConversations(loadMore: true) } catch { self.error = error.localizedDescription } } }.font(ChatStyle.font(12))
                    }
                }.padding(.horizontal, 20).padding(.vertical, 24)
            }
            .background(ChatStyle.background)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) { ChatHeader(title: "Messages", subtitle: client.replyTimeText, close: { dismiss() }) }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                VStack(spacing: 20) {
                    Button { path.append(0) } label: {
                        HStack(spacing: 8) {
                            Text("Start a new conversation").font(ChatStyle.buttonFont).tracking(-0.28).frame(minHeight: 21)
                            DesignIcon(name: "cw-next")
                        }
                            .padding(.horizontal, 16).frame(maxWidth: .infinity).frame(minHeight: 48)
                            .foregroundStyle(Color(hex: client.color).contrastingText)
                            .background(Color(hex: client.color), in: RoundedRectangle(cornerRadius: 12))
                    }.buttonStyle(.plain).disabled(!client.connected)
                    if !client.hideBranding { Branding() }
                }.padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 12).background(ChatStyle.background)
            }
            .navigationDestination(for: Int.self) { id in ConversationDestination(client: client, initialID: id == 0 ? nil : id, close: { dismiss() }) }
        }
        .id(client.sessionVersion)
        .task { await load() }
        .onChange(of: client.pendingConversationID) { _, id in if let id { path = [id]; client.consumeNotification() } }
        .onChange(of: scenePhase) { _, phase in if phase == .active { client.resume() } else { client.pause() } }
        .onDisappear { client.pause() }
    }
    private func load() async {
        loading = true; error = nil
        defer { loading = false }
        do {
            try await client.connect()
            client.resume()
            if let id = client.pendingConversationID { path = [id]; client.consumeNotification() }
            else if client.conversations.isEmpty && path.isEmpty { path = [0] }
        } catch { self.error = error.localizedDescription }
    }
}

private struct ChatHeader: View {
    let title: String
    var subtitle: String? = nil
    var back: (() -> Void)? = nil
    let close: () -> Void
    var body: some View {
        HStack(spacing: 8) {
            if let back { Button(action: back) { DesignIcon(name: "cw-back").frame(width: 44, height: 44).contentShape(Rectangle()) }.accessibilityLabel("Back to messages") }
            else { Color.clear.frame(width: 44, height: 44).accessibilityHidden(true) }
            VStack(spacing: 3) {
                Text(title).font(ChatStyle.font(16, medium: true)).foregroundStyle(ChatStyle.primary).lineLimit(2)
                if let subtitle { Text(subtitle).font(ChatStyle.font(14)).foregroundStyle(ChatStyle.secondary).lineLimit(1) }
            }.frame(maxWidth: .infinity)
            Button(action: close) { DesignIcon(name: back == nil ? "cw-close" : "cw-exit").frame(width: 44, height: 44).contentShape(Rectangle()) }.accessibilityLabel("Close support")
        }.buttonStyle(.plain).foregroundStyle(ChatStyle.secondary)
            .padding(.horizontal, 8).padding(.vertical, 14).frame(minHeight: 85).background(ChatStyle.surface)
            .overlay(alignment: .bottom) { ChatStyle.border.frame(height: 0.5) }
    }
}
private struct ConversationRow: View {
    let conversation: ChatwootConversation
    let title: String
    private var senderName: String { conversation.lastMessage?.messageType == 0 ? title : conversation.lastMessage?.sender?.name ?? title }
    private var preview: String {
        guard let message = conversation.lastMessage else { return "Start a conversation" }
        let text = message.content?.trimmingCharacters(in: .whitespacesAndNewlines)
        return (text?.isEmpty == false ? text : nil) ?? "Attachment"
    }
    var body: some View {
        HStack(spacing: 12) {
            Avatar(url: conversation.lastMessage?.messageType == 0 ? nil : conversation.lastMessage?.sender?.avatarUrl ?? conversation.lastMessage?.sender?.thumbnail, name: senderName)
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Text(senderName).font(ChatStyle.font(14, medium: true)).foregroundStyle(ChatStyle.primary).lineLimit(1).frame(minHeight: 21)
                    Spacer(minLength: 4)
                    if let date = conversation.lastMessage?.createdAt ?? conversation.lastActivityAt {
                        TimelineView(.periodic(from: .now, by: 60)) { context in
                            Text(ChatStyle.relativeTime(date, now: context.date)).font(ChatStyle.font(12)).foregroundStyle(ChatStyle.secondary).fixedSize()
                        }
                    }
                }
                HStack(spacing: 6) {
                    HStack(spacing: 2) {
                        if conversation.lastMessage?.messageType == 0 { DesignIcon(name: "cw-reply") }
                        Text(preview).font(ChatStyle.font(14)).lineLimit(1)
                    }.foregroundStyle(ChatStyle.secondary).frame(minHeight: 21).frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityElement(children: .ignore)
                        .accessibilityLabel((conversation.lastMessage?.messageType == 0 ? "You: " : "") + preview)
                    if let count = conversation.unreadCount, count > 0 {
                        Text(count > 99 ? "99+" : String(count)).font(ChatStyle.font(10, medium: true)).foregroundStyle(.white)
                            .padding(.horizontal, 4).frame(minWidth: 16, minHeight: 16).background(ChatStyle.unread, in: Capsule())
                    }
                }
            }
        }.padding(16).background(ChatStyle.surface, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(ChatStyle.border, lineWidth: 0.75))
            .accessibilityElement(children: .combine)
    }
}
private struct Avatar: View {
    let url: String?
    let name: String
    var size: CGFloat = 40
    var body: some View {
        AsyncImage(url: url.flatMap(URL.init(string:))) { image in image.resizable().scaledToFill() } placeholder: {
            Text(String(name.prefix(1)).uppercased()).font(ChatStyle.font(size * 0.4, medium: true))
                .foregroundStyle(ChatStyle.secondary).frame(maxWidth: .infinity, maxHeight: .infinity).background(ChatStyle.bubble)
        }.frame(width: size, height: size).clipShape(Circle()).overlay(Circle().stroke(ChatStyle.border, lineWidth: 1)).accessibilityHidden(true)
    }
}
private struct Branding: View {
    @Environment(\.colorScheme) private var colorScheme
    private var logo: some View {
        Image(uiImage: UIImage(contentsOfFile: Bundle.module.url(forResource: "chatwoot", withExtension: "png")!.path)!)
            .resizable().scaledToFit().frame(width: 60, height: 12)
    }
    var body: some View {
        HStack(spacing: 4) {
            Text("Powered by").font(ChatStyle.font(12))
            Group { if colorScheme == .dark { logo.colorInvert() } else { logo } }.opacity(0.5).accessibilityLabel("Chatwoot")
        }.foregroundStyle(ChatStyle.tertiary).accessibilityElement(children: .combine)
    }
}
private struct ErrorNotice: View {
    let text: String
    let retry: () -> Void
    var body: some View { VStack(spacing: 8) { Text(text).font(ChatStyle.font(12)); Button("Try again", action: retry) }.padding().frame(maxWidth: .infinity).background(Color.red.opacity(0.08), in: RoundedRectangle(cornerRadius: 12)) }
}

struct ChatScreen: View {
    @ObservedObject var client: ChatwootClient
    let initialID: Int?
    let close: () -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var conversationID: Int?
    @State private var messages: [ChatwootMessage] = []
    @State private var draft = ""
    @State private var loading = false
    @State private var sending = false
    @State private var error: String?
    @State private var sendError: String?
    @State private var hasOlder = true
    @State private var lastReadMessageID: Int?
    @State private var showFiles = false
    @State private var showEmoji = false
    @State private var photo: PhotosPickerItem?
    @State private var attachment: (Data, String, String)?
    @Environment(\.scenePhase) private var scenePhase
    private var canReply: Bool { client.allowRepliesAfterResolved || client.conversations.first(where: { $0.id == conversationID })?.status != "resolved" }
    private func isGrouped(_ index: Int, with other: Int) -> Bool {
        guard messages.indices.contains(other) else { return false }
        let a = messages[index], b = messages[other]
        return a.messageType == b.messageType && a.sender?.name == b.sender?.name && abs(a.createdAt - b.createdAt) < 120 && Calendar.current.isDate(Date(timeIntervalSince1970: a.createdAt), inSameDayAs: Date(timeIntervalSince1970: b.createdAt))
    }
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 0) {
                    if hasOlder && !messages.isEmpty { Button("Load earlier messages") { Task { await load(older: true) } }.font(ChatStyle.font(12)).padding(.bottom, 16) }
                    if loading && messages.isEmpty { ProgressView().padding(24) }
                    if let error { ErrorNotice(text: error) { Task { await load() } } }
                    if messages.isEmpty && !loading && error == nil {
                        VStack(spacing: 8) { Text("How can we help?").font(ChatStyle.font(20, medium: true)); Text("Send us a message to get started.").font(ChatStyle.font(14)).foregroundStyle(ChatStyle.secondary) }.padding(.vertical, 48)
                    }
                    ForEach(Array(messages.enumerated()), id: \.element.id) { index, message in
                        if index == 0 || !Calendar.current.isDate(Date(timeIntervalSince1970: message.createdAt), inSameDayAs: Date(timeIntervalSince1970: messages[index - 1].createdAt)) {
                            Text(Date(timeIntervalSince1970: message.createdAt).formatted(date: .abbreviated, time: .omitted))
                                .font(ChatStyle.font(12)).foregroundStyle(ChatStyle.secondary).padding(.horizontal, 8).padding(.vertical, 4)
                                .background(ChatStyle.input, in: RoundedRectangle(cornerRadius: 8)).padding(.bottom, 16).padding(.top, index == 0 ? 0 : 12)
                        }
                        MessageBubble(message: message, accent: Color(hex: client.color), outgoing: client.configuration.outgoingMessageColor.map(Color.init(hex:)), grouped: isGrouped(index, with: index - 1), read: message.createdAt <= (client.agentLastSeen[conversationID ?? 0] ?? 0), showMetadata: !isGrouped(index, with: index + 1)) { email in
                            try await client.submitEmail(email, messageID: message.id)
                            await load()
                        }.id(message.id).padding(.bottom, isGrouped(index, with: index + 1) ? 4 : 20)
                    }
                    Color.clear.frame(height: 1).id("bottom")
                }.padding(.horizontal, 20).padding(.top, 16)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: messages.last?.id) { _, _ in proxy.scrollTo("bottom", anchor: .bottom) }
        }
        .background(ChatStyle.background)
        .toolbar(.hidden, for: .navigationBar)
        .safeAreaInset(edge: .top, spacing: 0) { ChatHeader(title: client.title, subtitle: client.replyTimeText, back: { dismiss() }, close: close) }
        .safeAreaInset(edge: .bottom, spacing: 0) { composer }
        .task { conversationID = initialID; await load() }
        .onChange(of: client.revision) { _, _ in Task { await load() } }
        .onChange(of: scenePhase) { _, phase in if phase == .active { Task { await load() } } }
        .fileImporter(isPresented: $showFiles, allowedContentTypes: [.item]) { result in
            do {
                let url = try result.get(); let access = url.startAccessingSecurityScopedResource(); defer { if access { url.stopAccessingSecurityScopedResource() } }
                let type = try url.resourceValues(forKeys: [.contentTypeKey]).contentType
                attachment = (try Data(contentsOf: url), url.lastPathComponent, type?.preferredMIMEType ?? "application/octet-stream")
            } catch { sendError = error.localizedDescription }
        }
        .onChange(of: photo) { _, item in Task {
            do { if let data = try await item?.loadTransferable(type: Data.self) {
                let type = item?.supportedContentTypes.first ?? .jpeg
                attachment = (data, "image.\(type.preferredFilenameExtension ?? "jpg")", type.preferredMIMEType ?? "image/jpeg")
            } } catch { sendError = error.localizedDescription }
        } }
    }
    private var composer: some View {
        VStack(spacing: 12) {
            if let connectionError = client.connectionError { Text(connectionError).font(ChatStyle.font(12)).foregroundStyle(ChatStyle.secondary) }
            if let sendError { Text(sendError).font(ChatStyle.font(12)).foregroundStyle(.red).accessibilityLabel("Message not sent. \(sendError)") }
            if let attachment { HStack { Text(attachment.1).font(ChatStyle.font(12)).lineLimit(1); Spacer(); Button("Remove") { self.attachment = nil; photo = nil } }.padding(.horizontal, 8) }
            if canReply {
                HStack(alignment: .bottom, spacing: 0) {
                    TextField("Write a message…", text: $draft, prompt: Text("Write a message…").foregroundStyle(ChatStyle.tertiary), axis: .vertical).font(ChatStyle.font(14)).lineLimit(1...5)
                        .padding(.leading, 16).padding(.vertical, 12).disabled(sending)
                    if draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && attachment == nil && !sending {
                        if client.enabledFeatures.contains("attachments") {
                            Menu {
                                PhotosPicker(selection: $photo, matching: .images) { Label("Photo library", systemImage: "photo") }
                                Button("Choose file", systemImage: "doc") { showFiles = true }
                            } label: { DesignIcon(name: "cw-attach").frame(width: 44, height: 44).contentShape(Rectangle()) }
                                .accessibilityLabel("Add attachment").disabled(conversationID == nil)
                        }
                        if client.enabledFeatures.contains("emoji_picker") {
                            Button { showEmoji.toggle() } label: { DesignIcon(name: "cw-emoji").frame(width: 44, height: 44) }.accessibilityLabel("Choose emoji")
                                .popover(isPresented: $showEmoji) {
                                    LazyVGrid(columns: Array(repeating: GridItem(.fixed(44)), count: 5)) {
                                        ForEach(["😀", "😊", "🙂", "❤️", "👍", "🙏", "🎉", "👋", "🤔", "🙌"], id: \.self) { emoji in
                                            Button(emoji) { draft += emoji; showEmoji = false }.font(.system(size: 24)).frame(width: 44, height: 44)
                                        }
                                    }.padding(12).presentationCompactAdaptation(.popover)
                                }
                        }
                    } else {
                        Button { Task { await send() } } label: {
                            Group { if sending { ProgressView() } else { DesignIcon(name: "cw-send") } }.frame(width: 44, height: 44)
                        }.accessibilityLabel("Send message").disabled(sending)
                    }
                }.foregroundStyle(ChatStyle.secondary).buttonStyle(.plain).padding(.trailing, 4)
                    .background(ChatStyle.input, in: RoundedRectangle(cornerRadius: 10))
            } else { Text("This conversation is resolved. Start a new conversation for more help.").font(ChatStyle.font(12)).foregroundStyle(ChatStyle.secondary) }
            if !client.hideBranding { Branding() }
        }.padding(.horizontal, 24).padding(.top, 24).padding(.bottom, 16).background(LinearGradient(stops: [.init(color: ChatStyle.background.opacity(0), location: 0), .init(color: ChatStyle.background, location: 0.35)], startPoint: .top, endPoint: .bottom))
    }
    private func load(older: Bool = false) async {
        guard let id = conversationID else { return }
        guard !loading else { return }
        loading = true
        defer { loading = false }
        do {
            let page = try await client.messages(conversationID: id, before: older ? messages.first?.id : nil)
            if !older && messages.isEmpty { hasOlder = page.count >= 20 }
            if older { hasOlder = !page.isEmpty; messages = page.filter { item in !messages.contains(where: { $0.id == item.id }) } + messages }
            else { let IDs = Set(page.map(\.id)); messages = (messages.filter { !IDs.contains($0.id) } + page).sorted { $0.id < $1.id } }
            error = nil
            if scenePhase == .active, let lastID = messages.last?.id, lastReadMessageID != lastID {
                lastReadMessageID = lastID
                do { try await client.markRead(id) } catch { lastReadMessageID = nil; throw error }
            }
        } catch { self.error = error.localizedDescription }
    }
    private func send() async {
        sending = true; sendError = nil
        defer { sending = false }
        do {
            let content = draft.trimmingCharacters(in: .whitespacesAndNewlines)
            if !content.isEmpty { conversationID = try await client.send(content, conversationID: conversationID); draft = "" }
            if let attachment, let id = conversationID { try await client.upload(attachment.0, filename: attachment.1, mimeType: attachment.2, conversationID: id); self.attachment = nil; photo = nil }
            await load()
            try await client.refreshConversations()
        } catch { sendError = error.localizedDescription }
    }
}
private struct MessageBubble: View {
    let message: ChatwootMessage
    let accent: Color
    let outgoing: Color?
    let grouped: Bool
    let read: Bool
    let showMetadata: Bool
    let submitEmail: (String) async throws -> Void
    private var mine: Bool { message.messageType == 0 }
    var body: some View {
        VStack(alignment: mine ? .trailing : .leading, spacing: 6) {
            if message.messageType == 2 { Text(message.content ?? "").font(ChatStyle.font(12)).foregroundStyle(ChatStyle.secondary).frame(maxWidth: .infinity) }
            else {
                VStack(alignment: .leading, spacing: 10) {
                    if let text = message.content, !text.isEmpty {
                        Text((try? AttributedString(markdown: text, options: .init(interpretedSyntax: .inlineOnlyPreservingWhitespace))) ?? AttributedString(text)).textSelection(.enabled)
                    }
                    ForEach(message.attachments ?? []) { attachment in
                        if let url = URL(string: attachment.dataUrl) {
                            Link(destination: url) {
                                if attachment.fileType == "image" { AsyncImage(url: url) { image in image.resizable().scaledToFit() } placeholder: { ProgressView().frame(height: 100) }.frame(maxHeight: 240).clipShape(RoundedRectangle(cornerRadius: 8)) }
                                else { Label(url.lastPathComponent, systemImage: "doc").lineLimit(2) }
                            }
                        }
                    }
                    if message.contentType == "input_email" { EmailPrompt(submitted: message.contentAttributes?.submittedEmail, submit: submitEmail) }
                    else if let type = message.contentType, !["text", "incoming_email"].contains(type) {
                        Text("Please reply here and our team will help you.").font(ChatStyle.font(12)).foregroundStyle(ChatStyle.secondary)
                    }
                }.font(ChatStyle.font(14)).lineSpacing(4).foregroundStyle(mine ? outgoing?.contrastingText ?? ChatStyle.primary : ChatStyle.primary).padding(.horizontal, 12).padding(.vertical, 8)
                    .background(mine ? (outgoing ?? accent.opacity(0.14)) : ChatStyle.bubble, in: UnevenRoundedRectangle(topLeadingRadius: mine ? 12 : (grouped ? 2 : 16), bottomLeadingRadius: mine ? 12 : 2, bottomTrailingRadius: mine ? 2 : 16, topTrailingRadius: mine ? (grouped ? 2 : 12) : 16))
                if showMetadata {
                    HStack(spacing: 5) {
                        if !mine {
                            Avatar(url: message.sender?.avatarUrl ?? message.sender?.thumbnail, name: message.sender?.name ?? "Support", size: 16)
                            Text(message.sender?.name ?? "Support")
                            Image("cw-dot", bundle: .module).renderingMode(.template).resizable().frame(width: 4, height: 4).accessibilityHidden(true)
                        }
                        Text(Date(timeIntervalSince1970: message.createdAt), style: .time)
                        if mine {
                            if read { Image("cw-read", bundle: .module).renderingMode(.template).resizable().frame(width: 14, height: 14).foregroundStyle(Color(hex: "2781f6")).accessibilityLabel("Read") }
                            else { Image(systemName: "checkmark").font(.system(size: 11)).accessibilityLabel("Sent") }
                        }
                    }.font(ChatStyle.font(12)).foregroundStyle(ChatStyle.secondary)
                }
            }
        }.frame(maxWidth: .infinity, alignment: mine ? .trailing : .leading).padding(mine ? .leading : .trailing, 44)
    }
}
private struct EmailPrompt: View {
    let submitted: String?
    let submit: (String) async throws -> Void
    @State private var email = ""
    @State private var saved: String?
    @State private var saving = false
    @State private var error: String?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let value = submitted ?? saved {
                Label(value, systemImage: "checkmark.circle").font(ChatStyle.font(14)).foregroundStyle(ChatStyle.secondary)
            } else {
                HStack(spacing: 0) {
                    TextField("Your email address", text: $email, prompt: Text("Your email address").foregroundStyle(ChatStyle.tertiary)).font(ChatStyle.font(14)).keyboardType(.emailAddress).textContentType(.emailAddress)
                        .textInputAutocapitalization(.never).autocorrectionDisabled().padding(.leading, 12).disabled(saving)
                    Button { Task { await save() } } label: {
                        Group { if saving { ProgressView() } else { DesignIcon(name: "cw-next") } }.frame(width: 44, height: 44)
                    }.buttonStyle(.plain).disabled(saving || email.isEmpty).accessibilityLabel("Save email address")
                }.background(ChatStyle.surface, in: RoundedRectangle(cornerRadius: 8))
                if let error { Text(error).font(ChatStyle.font(12)).foregroundStyle(.red) }
            }
        }
    }
    private func save() async {
        let value = email.trimmingCharacters(in: .whitespacesAndNewlines)
        guard value.range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) != nil else { error = "Enter a valid email address."; return }
        saving = true; error = nil
        defer { saving = false }
        do { try await submit(value); saved = value } catch { self.error = "Couldn’t save your email. Please try again." }
    }
}
