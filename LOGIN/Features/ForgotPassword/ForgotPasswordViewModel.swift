import Foundation
import Observation

@Observable
@MainActor
final class ForgotPasswordViewModel {
    var email: String = "" { didSet { emailError = nil } }

    private(set) var emailError: String? = nil
    private(set) var isLoading: Bool = false
    var showCheckEmail: Bool = false

    func sendOTP() async {
        guard validate() else { return }
        isLoading = true
        defer { isLoading = false }
        // TODO: wire to forgot-password OTP endpoint once available
        try? await Task.sleep(for: .milliseconds(800))
        showCheckEmail = true
    }

    private func validate() -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty {
            emailError = String(localized: "Email is required")
            return false
        }
        if !isValidEmail(trimmed) {
            emailError = String(localized: "Enter a valid email address")
            return false
        }
        return true
    }

    private func isValidEmail(_ value: String) -> Bool {
        let regex = /^[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}$/
        return value.uppercased().wholeMatch(of: regex) != nil
    }
}
