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
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        !mobile.trimmingCharacters(in: .whitespaces).isEmpty &&
        !email.trimmingCharacters(in: .whitespaces).isEmpty &&
        !message.trimmingCharacters(in: .whitespaces).isEmpty
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
            try await authManager.submitContact(request)
            phase = .success("Your message has been sent! Our team will get back to you shortly.")
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
