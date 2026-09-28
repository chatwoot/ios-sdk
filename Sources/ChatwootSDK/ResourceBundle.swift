import Foundation

// Swift Package Manager synthesizes Bundle.module. CocoaPods uses a resource bundle.
#if !SWIFT_PACKAGE
private final class ChatwootBundleToken {}
extension Bundle {
    static let module = Bundle(url: Bundle(for: ChatwootBundleToken.self)
        .url(forResource: "ChatwootSDK", withExtension: "bundle")!)!
}
#endif
