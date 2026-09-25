import Foundation
import Security

enum SessionStore {
    static func query(_ key: String) -> [String: Any] {
        [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: "ChatwootSDK", kSecAttrAccount as String: key]
    }
    static func load(_ key: String) throws -> CustomerSession? {
        var q = query(key); q[kSecReturnData as String] = true
        var item: CFTypeRef?
        let status = SecItemCopyMatching(q as CFDictionary, &item)
        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess, let data = item as? Data else { throw ChatwootError.message("Could not read the customer session.") }
        return try JSONDecoder().decode(CustomerSession.self, from: data)
    }
    static func save(_ session: CustomerSession?, key: String) throws {
        let q = query(key)
        guard let session else {
            let status = SecItemDelete(q as CFDictionary)
            guard status == errSecSuccess || status == errSecItemNotFound else { throw ChatwootError.message("Could not clear the customer session.") }
            return
        }
        let data = try JSONEncoder().encode(session)
        var status = SecItemUpdate(q as CFDictionary, [kSecValueData as String: data] as CFDictionary)
        if status == errSecItemNotFound {
            var item = q
            item[kSecValueData as String] = data
            item[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
            status = SecItemAdd(item as CFDictionary, nil)
        }
        guard status == errSecSuccess else { throw ChatwootError.message("Could not save the customer session.") }
    }
}
