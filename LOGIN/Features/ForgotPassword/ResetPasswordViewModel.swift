import Foundation
import Observation

@Observable
@MainActor
final class ResetPasswordViewModel {
    var newPassword: String = ""        { didSet { newPasswordError = nil } }
    var confirmPassword: String = ""    { didSet { confirmPasswordError = nil } }
    var showNewPassword: Bool = false
    var showConfirmPassword: Bool = false

    private(set) var newPasswordError: String? = nil
    private(set) var confirmPasswordError: String? = nil
    private(set) var isLoading: Bool = false
    private(set) var isSuccess: Bool = false

    func resetPassword() async {
        guard validate() else { return }
        isLoading = true
        defer { isLoading = false }
        // TODO: wire to reset-password endpoint once available
        try? await Task.sleep(for: .milliseconds(800))
        isSuccess = true
    }

    private func validate() -> Bool {
        newPasswordError = nil
        confirmPasswordError = nil
        var valid = true

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
