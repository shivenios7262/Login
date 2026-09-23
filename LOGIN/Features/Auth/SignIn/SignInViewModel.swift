import Foundation
import Observation

@Observable
@MainActor
final class SignInViewModel {
    var email: String = ""    { didSet { if !email.isEmpty    { emailError    = nil } } }
    var password: String = "" { didSet { if !password.isEmpty { passwordError = nil } } }
    var showPassword: Bool = false
    var selectedUserType: UserType = .travelAgent

    private(set) var isLoading: Bool = false
    private(set) var emailError: String? = nil
    private(set) var passwordError: String? = nil
    private(set) var apiError: String? = nil
    private(set) var blockedError: String? = nil
    private(set) var showKYCSheet: Bool = false

    private let authManager: AuthManager
    private let router: AppRouter

    init(authManager: AuthManager, router: AppRouter) {
        self.authManager = authManager
        self.router = router
    }

    // MARK: - Actions

    func login() async {
        guard validate() else { return }
        isLoading = true
        apiError = nil
        blockedError = nil
        showKYCSheet = false
        defer { isLoading = false }

        do {
            try await authManager.login(
                email: email.trimmingCharacters(in: .whitespaces),
                password: password
            )
            router.presentAuth(.verifyOTP)
        } catch NetworkError.kycPending {
            showKYCSheet = true
        } catch NetworkError.accountBlocked(let message) {
            blockedError = "Your account is blocked due multiple wrong Password / OTP. Please contact admin for re-verification 73533 11550 or admin@ftd.travel."//message
        } catch let error as NetworkError {
            apiError = error.errorDescription
            
        } catch {
            apiError = error.localizedDescription
        }
    }

    func tapForgotPassword() {
        router.presentAuth(.forgotPassword)
    }

    func dismissKYCSheet() {
        showKYCSheet = false
    }

    // MARK: - Validation

    private func validate() -> Bool {
        emailError    = Validator.email(email)
        passwordError = password.isEmpty ? String(localized: "Password is required") : nil
        return emailError == nil && passwordError == nil
    }
}
