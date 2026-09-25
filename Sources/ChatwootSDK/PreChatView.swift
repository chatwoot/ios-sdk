import SwiftUI

struct ConversationDestination: View {
    @ObservedObject var client: ChatwootClient
    let initialID: Int?
    let close: () -> Void
    @State private var createdID: Int?
    var body: some View {
        if let id = initialID ?? createdID {
            ChatScreen(client: client, initialID: id, close: close)
        } else if client.preChatOptions != nil {
            PreChatView(client: client) { createdID = $0 }
        } else {
            ChatScreen(client: client, initialID: nil, close: close)
        }
    }
}
struct PreChatView: View {
    @ObservedObject var client: ChatwootClient
    let onCreated: (Int) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var values: [String: String] = [:]
    @State private var message = ""
    @State private var submitted = false
    @State private var sending = false
    @State private var error: String?
    @State private var dateField: PreChatField?
    @State private var date = Date()
    private let messageLimit = 250
    private func binding(_ field: PreChatField) -> Binding<String> { Binding(get: { values[field.name] ?? "" }, set: { values[field.name] = $0 }) }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(client.preChatOptions?.preChatMessage ?? "Please share your comments below")
                        .font(ChatStyle.font(18, medium: true)).foregroundStyle(ChatStyle.primary)
                    if let reply = client.replyTimeText { Text(reply).font(ChatStyle.font(14)).foregroundStyle(ChatStyle.secondary) }
                }.padding(.bottom, 24)
                ForEach(client.preChatFields) { field in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(field.label + (field.required ? " *" : "")).font(ChatStyle.font(14, medium: true))
                        input(field)
                        if submitted, let issue = PreChatSubmission.error(for: field, value: values[field.name] ?? "") {
                            Text(issue).font(ChatStyle.font(12)).foregroundStyle(.red)
                        }
                    }
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("Your message *").font(ChatStyle.font(14, medium: true))
                    VStack(alignment: .trailing, spacing: 4) {
                        TextField("Write your message here…", text: $message, prompt: Text("Write your message here…").foregroundStyle(ChatStyle.tertiary), axis: .vertical)
                            .font(ChatStyle.font(14)).lineLimit(2...6)
                        Text("\(message.count)/\(messageLimit)").font(ChatStyle.font(12)).foregroundStyle(message.count > messageLimit ? .red : ChatStyle.tertiary)
                    }.padding(12).background(ChatStyle.input, in: RoundedRectangle(cornerRadius: 10))
                    if submitted && message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty { Text("Enter a message.").font(ChatStyle.font(12)).foregroundStyle(.red) }
                    if message.count > messageLimit { Text("Keep your first message within \(messageLimit) characters.").font(ChatStyle.font(12)).foregroundStyle(.red) }
                }
                if let error { Text(error).font(ChatStyle.font(12)).foregroundStyle(.red) }
            }.foregroundStyle(ChatStyle.primary).padding(.horizontal, 20).padding(.top, 16).padding(.bottom, 24).disabled(sending)
        }.scrollDismissesKeyboard(.interactively).background(ChatStyle.background)
            .toolbar(.hidden, for: .navigationBar)
            .safeAreaInset(edge: .top, spacing: 0) {
                HStack {
                    Button { dismiss() } label: { HStack(spacing: 6) { DesignIcon(name: "cw-back"); Text("Back").font(ChatStyle.font(14)) }.frame(minHeight: 44) }
                    Spacer()
                }.buttonStyle(.plain).foregroundStyle(ChatStyle.primary).padding(.horizontal, 20).padding(.top, 8).background(ChatStyle.background)
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                Button { Task { await send() } } label: {
                    HStack(spacing: 8) { if sending { ProgressView() } else { Text("Send message"); DesignIcon(name: "cw-next") } }
                        .font(ChatStyle.font(14)).frame(maxWidth: .infinity).frame(minHeight: 48)
                        .foregroundStyle(Color(hex: client.color).contrastingText)
                        .background(Color(hex: client.color), in: RoundedRectangle(cornerRadius: 12))
                }.buttonStyle(.plain).disabled(sending).padding(20).background(ChatStyle.background)
            }
            .sheet(item: $dateField) { field in
                NavigationStack {
                    DatePicker(field.label, selection: $date, displayedComponents: .date).datePickerStyle(.graphical).padding()
                        .navigationTitle(field.label).navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dateField = nil } }
                            ToolbarItem(placement: .confirmationAction) { Button("Done") { values[field.name] = Self.dateFormatter.string(from: date); dateField = nil } }
                        }
                }.presentationDetents([.medium])
            }
    }
    @ViewBuilder private func input(_ field: PreChatField) -> some View {
        if field.type == "checkbox" {
            Toggle("\(field.label)", isOn: Binding(get: { values[field.name] == "true" }, set: { values[field.name] = $0 ? "true" : "false" })).labelsHidden().tint(Color(hex: client.color)).frame(maxWidth: .infinity, alignment: .leading)
        } else if ["list", "select"].contains(field.type) {
            Menu {
                Button("Choose an option") { values[field.name] = "" }
                ForEach(field.values ?? [], id: \.self) { option in Button(option) { values[field.name] = option } }
            } label: {
                HStack { Text(values[field.name].flatMap { $0.isEmpty ? nil : $0 } ?? field.placeholder ?? "Choose an option").frame(maxWidth: .infinity, alignment: .leading); DesignIcon(name: "cw-down") }
                    .font(ChatStyle.font(14)).padding(.horizontal, 16).frame(minHeight: 44).background(ChatStyle.input, in: RoundedRectangle(cornerRadius: 10))
            }.buttonStyle(.plain)
        } else if field.type == "date" {
            Button { date = Self.dateFormatter.date(from: values[field.name] ?? "") ?? Date(); dateField = field } label: {
                HStack { Text(values[field.name] ?? "Choose a date"); Spacer(); Image(systemName: "calendar") }.font(ChatStyle.font(14)).padding(.horizontal, 16).frame(minHeight: 44).background(ChatStyle.input, in: RoundedRectangle(cornerRadius: 10))
            }.buttonStyle(.plain)
        } else {
            TextField(field.label, text: binding(field), prompt: Text(field.placeholder ?? "Enter \(field.label.lowercased())").foregroundStyle(ChatStyle.tertiary), axis: field.type == "textarea" ? .vertical : .horizontal)
                .font(ChatStyle.font(14)).lineLimit(field.type == "textarea" ? 3...6 : 1...1)
                .keyboardType(field.name == "phoneNumber" ? .phonePad : field.type == "email" ? .emailAddress : field.type == "number" ? .numbersAndPunctuation : ["link", "url"].contains(field.type) ? .URL : .default)
                .textInputAutocapitalization(field.name == "fullName" ? .words : .never).autocorrectionDisabled()
                .padding(.horizontal, 16).padding(.vertical, 12).background(ChatStyle.input, in: RoundedRectangle(cornerRadius: 10))
                .accessibilityLabel(field.label)
        }
    }
    private static let dateFormatter: DateFormatter = { let formatter = DateFormatter(); formatter.locale = Locale(identifier: "en_US_POSIX"); formatter.dateFormat = "yyyy-MM-dd"; return formatter }()
    private func send() async {
        submitted = true; error = nil
        guard !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty, message.count <= messageLimit,
              client.preChatFields.allSatisfy({ PreChatSubmission.error(for: $0, value: values[$0.name] ?? "") == nil }) else { return }
        sending = true
        defer { sending = false }
        do { onCreated(try await client.startConversation(message: message, preChatValues: values)) }
        catch { self.error = error.localizedDescription }
    }
}
