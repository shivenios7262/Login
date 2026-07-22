import Testing
@testable import LOGIN

// Exercises the real Keychain API (works in the iOS simulator).
// .serialized: Keychain tests share the same keys, so they must run sequentially.
@Suite("KeychainService", .serialized)
struct KeychainServiceTests {
    let sut = KeychainService()

    @Test("Save and read round-trip")
    func saveAndRead() {
        sut.delete(key: .appToken)
        sut.save(key: .appToken, value: "test-value")
        #expect(sut.read(key: .appToken) == "test-value")
        sut.delete(key: .appToken)
    }

    @Test("Delete removes stored value")
    func deleteRemovesValue() {
        sut.save(key: .appToken, value: "to-delete")
        sut.delete(key: .appToken)
        #expect(sut.read(key: .appToken) == nil)
    }

    @Test("Saving the same key twice overwrites the first value")
    func overwriteReplacesValue() {
        sut.delete(key: .appToken)
        sut.save(key: .appToken, value: "first")
        sut.save(key: .appToken, value: "second")
        #expect(sut.read(key: .appToken) == "second")
        sut.delete(key: .appToken)
    }

    @Test("Read returns nil for key that was never saved")
    func readMissingKeyReturnsNil() {
        sut.delete(key: .authToken)
        #expect(sut.read(key: .authToken) == nil)
    }
}
