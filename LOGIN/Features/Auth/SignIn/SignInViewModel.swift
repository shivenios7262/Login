import Foundation
import Observation

@Observable
@MainActor
final class SignInViewModel {
    var email: String = "" {
        didSet { if !email.isEmpty { emailError = nil } }
    }
    var password: String = "" {
        didSet { if !password.isEmpty { passwordError = nil } }
    }
    var showPassword: Bool = false
    var selectedUserType: UserType = .travelAgent
    var showForgotPassword: Bool = false
    var showOTP: Bool = false

    private(set) var isLoading: Bool = false
    private(set) var emailError: String? = nil
    private(set) var passwordError: String? = nil
    private(set) var apiError: String? = nil

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func login() async {
        guard validate() else { return }
        isLoading = true
        apiError = nil
        defer { isLoading = false }

        do {
            try await authManager.login(email: email.trimmingCharacters(in: .whitespaces),
                                        password: password)
            showOTP = true
        } catch let error as NetworkError {
            apiError = error.errorDescription
        } catch {
            apiError = error.localizedDescription
        }
    }

    // MARK: - Private

    private func validate() -> Bool {
        emailError = nil
        passwordError = nil
        var valid = true

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        if trimmedEmail.isEmpty {
            emailError = String(localized: "Email is required")
            valid = false
        } else if !isValidEmail(trimmedEmail) {
            emailError = String(localized: "Enter a valid email address")
            valid = false
        }

        if password.isEmpty {
            passwordError = String(localized: "Password is required")
            valid = false
        }

        return valid
    }

    private func isValidEmail(_ value: String) -> Bool {
        let regex = /^[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}$/
        return value.uppercased().wholeMatch(of: regex) != nil
    }
}
