import Foundation
import Observation

@Observable
@MainActor
final class VerifyOTPViewModel {
    var otp: String = "" {
        didSet {
            if !otp.isEmpty {
                apiError = nil
                resendMessage = nil
            }
        }
    }
    private(set) var isLoading = false
    private(set) var isResending = false
    private(set) var apiError: String? = nil
    private(set) var resendMessage: String? = nil
    private(set) var resendCooldown: Int = 60

    private let authManager: AuthManager
    private var timerTask: Task<Void, Never>?

    init(authManager: AuthManager) {
        self.authManager = authManager
        startResendTimer()
    }

    var otpEmail: String { authManager.pendingOTPEmail ?? "" }

    var timerDisplay: String {
        let m = resendCooldown / 60
        let s = resendCooldown % 60
        return String(format: "%02d:%02d", m, s)
    }

    var canResend: Bool { resendCooldown == 0 && !isResending }

    // MARK: - Actions

    func verify() async {
        let trimmed = otp.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else {
            apiError = String(localized: "Please enter the OTP")
            return
        }
        isLoading = true
        apiError = nil
        defer { isLoading = false }
        do {
            try await authManager.verifyOTP(otp: trimmed)
        } catch let error as NetworkError {
            apiError = error.errorDescription
        } catch {
            apiError = error.localizedDescription
        }
    }

    func resend() async {
        guard canResend else { return }
        isResending = true
        apiError = nil
        resendMessage = nil
        defer { isResending = false }
        do {
            let message = try await authManager.resendOTP()
            otp = ""
            resendMessage = message
            startResendTimer()
        } catch let error as NetworkError {
            apiError = error.errorDescription
        } catch {
            apiError = error.localizedDescription
        }
    }

    func onDisappear() {
        timerTask?.cancel()
        if !authManager.isLoggedIn {
            authManager.cancelPendingOTP()
        }
    }

    // MARK: - Private

    private func startResendTimer() {
        resendCooldown = 180
        timerTask?.cancel()
        timerTask = Task { [weak self] in
            while let self, self.resendCooldown > 0 {
                try? await Task.sleep(for: .seconds(1))
                if Task.isCancelled { break }
                self.resendCooldown -= 1
            }
        }
    }
}
