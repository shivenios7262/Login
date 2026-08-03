import Foundation
import Observation
import UIKit

@Observable
@MainActor
final class AuthManager {
    private(set) var currentUser: User?
    private(set) var isLoggedIn = false
    private(set) var hasAppToken = false
    private(set) var pendingAgentNo: String? = nil
    private(set) var pendingOTPEmail: String? = nil

    private let apiClient: APIClient
    private let keychain: KeychainServiceProtocol

    init(apiClient: APIClient, keychain: KeychainServiceProtocol) {
        self.apiClient = apiClient
        self.keychain = keychain
        restoreSession()
    }

    // MARK: - App Token

    func fetchAppToken() async throws {
        try await apiClient.prepareAppToken()
        hasAppToken = true
    }

    // MARK: - Agent Login → OTP → Authenticated

    func login(email: String, password: String) async throws {
        let deviceId = resolveDeviceId()
        let request = AgentLoginRequest(email: email, password: password, deviceId: deviceId)
        let response: AgentLoginResponse = try await apiClient.send(.agentLogin(request))

        guard response.status, let data = response.data else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Login failed. Please check your credentials.")
            )
        }

        pendingAgentNo = data.agentNo
        pendingOTPEmail = data.email ?? email
    }

    func verifyOTP(otp: String) async throws {
        guard let agentNo = pendingAgentNo else {
            throw NetworkError.serverError(String(localized: "No active OTP session."))
        }

        let bounds = UIScreen.main.bounds
        let request = VerifyOTPRequest(
            agentNo: agentNo,
            otp: otp,
            deviceId: resolveDeviceId(),
            screenSize: "\(Int(bounds.width))x\(Int(bounds.height))",
            deviceModel: UIDevice.current.model,
            osVersion: UIDevice.current.systemVersion
        )
        let response: VerifyOTPResponse = try await apiClient.send(.verifyOTP(request))

        guard response.status, let data = response.data else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "OTP verification failed.")
            )
        }

        keychain.save(key: .authToken, value: data.accessToken)
        keychain.save(key: .refreshToken, value: data.refreshToken)
        if let expiry = data.accessTokenExpiry {
            keychain.save(key: .accessTokenExpiry, value: expiry)
        }
        if let expiry = data.refreshTokenExpiry {
            keychain.save(key: .refreshTokenExpiry, value: expiry)
        }

        let user = data.user
        if let encoded = try? JSONEncoder().encode(user),
           let json = String(data: encoded, encoding: .utf8) {
            keychain.save(key: .userData, value: json)
        }
        currentUser = user

        pendingAgentNo = nil
        pendingOTPEmail = nil
        isLoggedIn = true
    }

    @discardableResult
    func resendOTP() async throws -> String? {
        guard let agentNo = pendingAgentNo else { return nil }
        let request = ResendOTPRequest(agentNo: agentNo)
        let response: ResendOTPResponse = try await apiClient.send(.resendOTP(request))
        if !response.status {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Failed to resend OTP.")
            )
        }
        return response.serverMessage
    }

    func fetchBookings(request: AgentBookingsRequest) async throws -> AgentBookingsResponse {
        return try await apiClient.send(.agentBookings(request))
    }

    func fetchProfile() async throws -> AgentProfileResponse {
        return try await apiClient.send(.agentProfile)
    }

    func fetchStatement(request: AgencyStatementRequest) async throws -> AgencyStatementResponse {
        return try await apiClient.send(.agencyStatement(request))
    }

    func fetchMarkups() async throws -> AgentMarkupsResponse {
        return try await apiClient.send(.agentMarkups)
    }

    func register(request: AgentRegisterRequest) async throws {
        let response: GenericAPIResponse = try await apiClient.send(.agentRegister(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Registration failed. Please try again.")
            )
        }
    }

    func cancelPendingOTP() {
        pendingAgentNo = nil
        pendingOTPEmail = nil
    }

    // Called silently from HomeView.task on every relaunch.
    func checkAndRefreshTokenIfNeeded() async {
        guard isLoggedIn else { return }
        do {
            try await apiClient.ensureValidAccessToken()
        } catch {
            // Session expired or refresh failed — force logout.
            logout()
        }
    }

    func logout() {
        keychain.delete(key: .authToken)
        keychain.delete(key: .refreshToken)
        keychain.delete(key: .accessTokenExpiry)
        keychain.delete(key: .refreshTokenExpiry)
        keychain.delete(key: .userData)
        currentUser = nil
        pendingAgentNo = nil
        isLoggedIn = false
        // appToken kept in keychain — routes to AuthContainerView on next launch, skipping Splash
    }

    // MARK: - Private

    private func restoreSession() {
        isLoggedIn = keychain.read(key: .authToken) != nil
        hasAppToken = AppConfiguration.appCredentials.persistAppToken && keychain.read(key: .appToken) != nil
        if let json = keychain.read(key: .userData),
           let data = json.data(using: .utf8),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            currentUser = user
        }
        //isLoggedIn = true
    }

    private func resolveDeviceId() -> String {
        // Prefer the hardware-stable vendor ID; fall back to a stored UUID if unavailable.
//        if let vendorId = UIDevice.current.identifierForVendor?.uuidString {
//            keychain.save(key: .deviceId, value: vendorId)
//            return vendorId
//        }
//        if let existing = keychain.read(key: .deviceId) { return existing }
        let newId = UUID().uuidString
        keychain.save(key: .deviceId, value: newId)
        return newId
    }
}
