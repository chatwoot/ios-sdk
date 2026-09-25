import Foundation

public struct PreChatOptions: Decodable {
    public let preChatMessage: String?
    public let preChatFields: [PreChatField]?
}
public struct PreChatField: Decodable, Identifiable {
    public var id: String { name }
    public let name: String
    public let type: String
    public let label: String
    public let placeholder: String?
    public let enabled: Bool
    public let required: Bool
    public let fieldType: String
    public let values: [String]?
    public let regexPattern: String?
    public let regexCue: String?
}
enum PreChatSubmission {
    static func error(for field: PreChatField, value: String) -> String? {
        let value = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if field.required && (value.isEmpty || (field.type == "checkbox" && value != "true")) { return "This field is required." }
        let supported = ["text", "textarea", "email", "number", "date", "checkbox", "list", "select", "link", "url"]
        guard supported.contains(field.type) else { return "This field is not supported yet. Please contact the support team." }
        if value.isEmpty { return nil }
        if field.name == "emailAddress" || field.type == "email" {
            if value.range(of: #"^[^\s@]+@[^\s@]+\.[^\s@]+$"#, options: .regularExpression) == nil { return "Enter a valid email address." }
        }
        if field.name == "phoneNumber", value.range(of: #"^\+[1-9][0-9]{6,14}$"#, options: .regularExpression) == nil { return "Include the country code, for example +14155552671." }
        if ["list", "select"].contains(field.type), !(field.values ?? []).contains(value) { return "Choose an option from the list." }
        if field.type == "number", Double(value)?.isFinite != true { return "Enter a valid number." }
        if ["url", "link"].contains(field.type), URL(string: value)?.host == nil { return "Enter a complete URL." }
        if field.type == "date" {
            let formatter = DateFormatter(); formatter.locale = Locale(identifier: "en_US_POSIX"); formatter.dateFormat = "yyyy-MM-dd"; formatter.isLenient = false
            if formatter.date(from: value) == nil { return "Choose a valid date." }
        }
        if let pattern = field.regexPattern, !pattern.isEmpty {
            var source = pattern
            var options: NSRegularExpression.Options = []
            if source.hasPrefix("/"), let end = source.lastIndex(of: "/"), end != source.startIndex {
                let flags = String(source[source.index(after: end)...])
                if flags.contains("i") { options.insert(.caseInsensitive) }
                if flags.contains("m") { options.insert(.anchorsMatchLines) }
                source = String(source[source.index(after: source.startIndex)..<end])
            }
            guard let regex = try? NSRegularExpression(pattern: source, options: options) else { return "This field’s validation could not be loaded. Please contact the support team." }
            if regex.firstMatch(in: value, range: NSRange(value.startIndex..., in: value)) == nil { return field.regexCue ?? "Enter a value in the requested format." }
        }
        return nil
    }
    static func payload(fields: [PreChatField], values: [String: String], message: String) throws -> [String: Any] {
        let message = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !message.isEmpty else { throw ChatwootError.message("Enter a message.") }
        var contact: [String: Any] = [:], contactAttributes: [String: Any] = [:], conversationAttributes: [String: Any] = [:]
        for field in fields {
            let value = (values[field.name] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if let error = error(for: field, value: value) { throw ChatwootError.message("\(field.label): \(error)") }
            let typed: Any = field.type == "checkbox" ? value == "true" : field.type == "number" && !value.isEmpty ? Double(value)! as Any : value.isEmpty ? NSNull() : value as Any
            switch field.fieldType {
            case "contact_attribute": contactAttributes[field.name] = typed
            case "conversation_attribute": conversationAttributes[field.name] = typed
            default:
                if let key = ["fullName": "name", "emailAddress": "email", "phoneNumber": "phone_number"][field.name], !value.isEmpty { contact[key] = value }
            }
        }
        contact["custom_attributes"] = contactAttributes
        return ["contact": contact, "custom_attributes": conversationAttributes, "message": ["content": message, "timestamp": Int(Date().timeIntervalSince1970)]]
    }
}
