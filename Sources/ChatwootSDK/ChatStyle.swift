import SwiftUI
import CoreText

// Live Chat V2 tokens. Colors have light and dark variants in Chatwoot.xcassets.
enum ChatStyle {
    static let background = Color("Background", bundle: .module)
    static let surface = Color("Surface", bundle: .module)
    static let border = Color("Border", bundle: .module)
    static let primary = Color("TextPrimary", bundle: .module)
    static let secondary = Color("TextSecondary", bundle: .module)
    static let tertiary = Color("TextTertiary", bundle: .module)
    static let bubble = Color("Bubble", bundle: .module)
    static let input = Color("Input", bundle: .module)
    static let unread = Color("Unread", bundle: .module)
    private static let fonts: [String] = ["Inter-420-20", "Inter-500-24", "Inter-460-14"].map { resource in
        let url = Bundle.module.url(forResource: resource, withExtension: "ttf")!
        CTFontManagerRegisterFontsForURL(url as CFURL, .process, nil)
        let descriptors = CTFontManagerCreateFontDescriptorsFromURL(url as CFURL) as! [CTFontDescriptor]
        return CTFontCopyPostScriptName(CTFontCreateWithFontDescriptor(descriptors[0], 14, nil)) as String
    }
    static func font(_ size: CGFloat, medium: Bool = false) -> Font {
        .custom(fonts[medium ? 1 : 0], size: size, relativeTo: size >= 16 ? .headline : size <= 12 ? .caption : .subheadline)
    }
    static let buttonFont = Font.custom(fonts[2], size: 14, relativeTo: .subheadline)

    static func relativeTime(_ timestamp: Double, now: Date) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let seconds = max(0, now.timeIntervalSince(date))
        if seconds < 60 { return "Now" }
        if seconds < 3600 { return "\(Int(seconds / 60))m ago" }
        if seconds < 86400 { return "\(Int(seconds / 3600))h ago" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(.dateTime.month(.abbreviated).day())
    }
}
struct DesignIcon: View {
    let name: String
    var body: some View {
        Image(name, bundle: .module).renderingMode(.template).resizable().frame(width: 16, height: 16).accessibilityHidden(true)
    }
}
extension Color {
    init(hex: String) {
        let value = UInt64(hex.trimmingCharacters(in: CharacterSet(charactersIn: "#")), radix: 16) ?? 0x2781f6
        self.init(red: Double((value >> 16) & 255) / 255, green: Double((value >> 8) & 255) / 255, blue: Double(value & 255) / 255)
    }
    var contrastingText: Color {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let values = [red, green, blue].map { $0 <= 0.04045 ? $0 / 12.92 : pow(($0 + 0.055) / 1.055, 2.4) }
        let luminance = values[0] * 0.2126 + values[1] * 0.7152 + values[2] * 0.0722
        return luminance > 0.179 ? .black : .white
    }
}
