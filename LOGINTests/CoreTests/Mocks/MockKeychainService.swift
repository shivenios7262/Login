import Foundation
@testable import LOGIN

final class MockKeychainService: KeychainServiceProtocol, @unchecked Sendable {
    private var storage: [String: String] = [:]

    nonisolated func save(key: KeychainKey, value: String) {
        storage[key.rawValue] = value
    }

    @discardableResult nonisolated func delete(key: KeychainKey) -> Bool {
        storage.removeValue(forKey: key.rawValue) != nil
    }

    nonisolated func read(key: KeychainKey) -> String? {
        storage[key.rawValue]
    }
}
