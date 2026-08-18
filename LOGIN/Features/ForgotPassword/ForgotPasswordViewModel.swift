import Foundation
import Observation

@Observable
@MainActor
final class ForgotPasswordViewModel {
    var email: String = "" { didSet { emailError = nil; apiError = nil } }

    private(set) var emailError: String? = nil
    private(set) var apiError: String? = nil
    private(set) var isLoading: Bool = false
    private(set) var showSuccess: Bool = false

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func sendResetLink() async {
        guard validate() else { return }
        isLoading = true
        apiError = nil
        defer { isLoading = false }
        do {
            try await authManager.forgotPasswordLink(
                agentEmail: email.trimmingCharacters(in: .whitespaces)
            )
            showSuccess = true
        } catch let error as NetworkError {
            apiError = error.errorDescription
        } catch {
            apiError = error.localizedDescription
        }
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
