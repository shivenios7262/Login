import Foundation
import Security

enum KeychainKey: String, CaseIterable {
    case appToken            = "com.ftd.appToken"
    case authToken           = "com.ftd.authToken"
    case refreshToken        = "com.ftd.refreshToken"
    case accessTokenExpiry   = "com.ftd.accessTokenExpiry"
    case refreshTokenExpiry  = "com.ftd.refreshTokenExpiry"
    case deviceId            = "com.ftd.deviceId"
    case userData            = "com.ftd.userData"
}

protocol KeychainServiceProtocol: Sendable {
    // nonisolated: callable from any actor. Required because SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor
    // would otherwise infer @MainActor on all protocol methods.
    nonisolated func save(key: KeychainKey, value: String)
    @discardableResult nonisolated func delete(key: KeychainKey) -> Bool
    nonisolated func read(key: KeychainKey) -> String?
}

// All Keychain operations are synchronous (Security framework is blocking internally).
// kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly:
//   - Token survives device restarts (available after first unlock).
//   - NOT transferred via iCloud Keychain or device-to-device migration — tokens are device-bound.
final class KeychainService: KeychainServiceProtocol, @unchecked Sendable {
    // nonisolated let: immutable CFString constant, safe to read from any context.
    nonisolated private let accessibility = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

    nonisolated func save(key: KeychainKey, value: String) {
        guard let data = value.data(using: .utf8) else { return }

        let baseQuery: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecAttrAccessible: accessibility
        ]
        SecItemDelete(baseQuery as CFDictionary)

        var addQuery = baseQuery
        addQuery[kSecValueData] = data
        SecItemAdd(addQuery as CFDictionary, nil)
    }

    @discardableResult nonisolated func delete(key: KeychainKey) -> Bool {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue
        ]
        return SecItemDelete(query as CFDictionary) == errSecSuccess
    }

    nonisolated func read(key: KeychainKey) -> String? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key.rawValue,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        var result: AnyObject?
        guard SecItemCopyMatching(query as CFDictionary, &result) == errSecSuccess,
              let data = result as? Data
        else { return nil }
        return String(data: data, encoding: .utf8)
    }
}
