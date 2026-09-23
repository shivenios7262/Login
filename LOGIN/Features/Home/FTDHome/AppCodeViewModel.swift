import Foundation
import Observation

@Observable
@MainActor
final class AppCodeViewModel {
    private(set) var isLoading = true
    private(set) var apiError: String? = nil
    private(set) var otpCode: String? = nil
    private(set) var otpExpiryDate: Date? = nil

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func reset() {
        otpCode = nil
        otpExpiryDate = nil
        apiError = nil
        isLoading = true
    }

    func fetchCode() async {
        otpCode = nil
        otpExpiryDate = nil
        isLoading = true
        apiError = nil
        defer { isLoading = false }

        do {
            let result = try await authManager.getAppCode()
            if let code = result.code, !code.isEmpty {
                otpCode = code
                otpExpiryDate = result.expiryDate
            } else {
                // apiError = String(localized: "Your app code has expired. Please request a new one from the web portal.")
                let retry = try await authManager.getAppCode()
                if let code = retry.code, !code.isEmpty {
                    otpCode = code
                    otpExpiryDate = retry.expiryDate
                } else {
                    apiError = String(localized: "Your app code has expired. Please request a new one from the web portal.")
                }
            }
        } catch let e as NetworkError {
            apiError = e.errorDescription
        } catch {
            apiError = error.localizedDescription
        }
    }
}
