import Foundation
import Observation

@Observable
@MainActor
final class ResetPasswordViewModel {
    var agentNo: String = ""         { didSet { agentNoError = nil; apiError = nil } }
    var newPassword: String = ""     { didSet { newPasswordError = nil; apiError = nil } }
    var confirmPassword: String = "" { didSet { confirmPasswordError = nil; apiError = nil } }
    var showNewPassword: Bool = false
    var showConfirmPassword: Bool = false

    private(set) var agentNoError: String? = nil
    private(set) var newPasswordError: String? = nil
    private(set) var confirmPasswordError: String? = nil
    private(set) var apiError: String? = nil
    private(set) var isLoading: Bool = false
    private(set) var isSuccess: Bool = false

    private let authManager: AuthManager
    private let email: String

    init(authManager: AuthManager, email: String) {
        self.authManager = authManager
        self.email = email
    }

    func resetPassword() async {
        guard validate() else { return }
        isLoading = true
        apiError = nil
        defer { isLoading = false }
        do {
            try await authManager.forgotPassword(
                ForgotPasswordRequest(
                    email: email,
                    agentNo: agentNo.trimmingCharacters(in: .whitespaces),
                    password: newPassword,
                    passconf: confirmPassword
                )
            )
            isSuccess = true
        } catch let error as NetworkError {
            apiError = error.errorDescription
        } catch {
            apiError = error.localizedDescription
        }
    }

    private func validate() -> Bool {
        agentNoError = nil
        newPasswordError = nil
        confirmPasswordError = nil
        var valid = true

        if agentNo.trimmingCharacters(in: .whitespaces).isEmpty {
            agentNoError = String(localized: "Agent number is required")
            valid = false
        }
        if newPassword.isEmpty {
            newPasswordError = String(localized: "New password is required")
            valid = false
        } else if newPassword.count < 8 {
            newPasswordError = String(localized: "Password must be at least 8 characters")
            valid = false
        }
        if confirmPassword.isEmpty {
            confirmPasswordError = String(localized: "Please confirm your password")
            valid = false
        } else if newPassword != confirmPassword {
            confirmPasswordError = String(localized: "Passwords do not match")
            valid = false
        }
        return valid
    }
}
