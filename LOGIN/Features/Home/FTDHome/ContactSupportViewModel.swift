import Foundation
import Observation

@Observable
@MainActor
final class ContactSupportViewModel {

    enum Phase {
        case idle
        case submitting
        case success(String)
        case failure(String)
    }

    var name: String    = ""
    var mobile: String  = ""
    var email: String   = ""
    var message: String = ""

    private(set) var phase: Phase = .idle

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    var isSubmitting: Bool {
        if case .submitting = phase { return true }
        return false
    }

    var isFormValid: Bool {
        Validator.requiredText(name, fieldName: "Name") == nil &&
        Validator.phone(mobile) == nil &&
        Validator.email(email) == nil &&
        Validator.requiredText(message, fieldName: "Message") == nil
    }

    var nameError: String? {
        name.isEmpty ? nil : Validator.requiredText(name, fieldName: "Name")
    }

    var mobileError: String? {
        mobile.isEmpty ? nil : Validator.phone(mobile)
    }

    var emailError: String? {
        email.isEmpty ? nil : Validator.email(email)
    }

    var messageError: String? {
        message.isEmpty ? nil : Validator.requiredText(message, fieldName: "Message")
    }

    func submit() async {
        phase = .submitting
        let request = ContactRequest(
            name:    name.trimmingCharacters(in: .whitespaces),
            email:   email.trimmingCharacters(in: .whitespaces),
            phone:   mobile.trimmingCharacters(in: .whitespaces),
            message: message.trimmingCharacters(in: .whitespaces)
        )
        do {
            let message = try await authManager.submitContact(request)
            phase = .success(message)
        } catch {
            phase = .failure(error.localizedDescription)
        }
    }

    func reset() {
        phase   = .idle
        name    = ""
        mobile  = ""
        email   = ""
        message = ""
    }

    func dismissAlert() {
        if case .success = phase { reset() }
        if case .failure = phase { phase = .idle }
    }
}
