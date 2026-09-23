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
        clearKeychainOnVersionChange()
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
            let message = response.errorDesc ?? response.message
                ?? String(localized: "Login failed. Please check your credentials.")
            if response.errorCode == 1104 {
                throw NetworkError.kycPending
            }
            if response.errorCode == 1105 {
                throw NetworkError.accountBlocked(message)
            }
            throw NetworkError.serverError(message)
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
            deviceModel: DeviceInfo.modelIdentifier,
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

    func refreshBalance() async {
        guard isLoggedIn, let user = currentUser else { return }
        do {
            let response: AgentBalanceResponse = try await apiClient.send(.agentBalance)
            guard response.status, let data = response.data else { return }
            let updated = user.withUpdatedBalance(
                agencyName: data.agencyName,
                mobileNo: data.mobileNo,
                agentLogo: data.agentLogo,
                credit: data.creditBalance,
                booking: data.bookingBalance
            )
            currentUser = updated
            if let encoded = try? JSONEncoder().encode(updated),
               let json = String(data: encoded, encoding: .utf8) {
                keychain.save(key: .userData, value: json)
            }
        } catch { /* fail silently — stale balance is acceptable */ }
    }

    @discardableResult
    func submitGroupFaresRequest(_ request: GroupFaresRequest) async throws -> String {
        let response: GroupFaresAPIResponse = try await apiClient.send(.groupFaresRequest(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.message ?? String(localized: "Failed to submit group fare request.")
            )
        }
        return response.data?.referenceNo ?? ""
    }

    func fetchBookings(request: AgentBookingsRequest) async throws -> AgentBookingsResponse {
        return try await apiClient.send(.agentBookings(request))
    }

    func fetchRefunds(request: AgentRefundsRequest) async throws -> AgentRefundsResponse {
        return try await apiClient.send(.agentRefunds(request))
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

    func saveMarkups(_ request: AgentSaveMarkupsRequest) async throws {
        let response: GenericAPIResponse = try await apiClient.send(.agentSaveMarkups(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Failed to save markups.")
            )
        }
    }

    func fetchCountries() async throws -> [CountryItem] {
        let response: CountriesResponse = try await apiClient.send(.countries)
        guard response.status, let data = response.data else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Failed to fetch countries.")
            )
        }
        return data
    }

    func forgotPassword(_ request: ForgotPasswordRequest) async throws {
        let response: GenericAPIResponse = try await apiClient.send(.forgotPassword(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Password reset failed. Please try again.")
            )
        }
    }

    func forgotPasswordLink(agentEmail: String) async throws {
        let request = ForgotPasswordLinkRequest(agentEmail: agentEmail)
        let response: GenericAPIResponse = try await apiClient.send(.forgotPasswordLink(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Failed to send reset link. Please try again.")
            )
        }
    }

    @discardableResult
    func register(request: AgentRegisterRequest) async throws -> String? {
        let response: AgentRegisterResponse = try await apiClient.send(.agentRegister(request))
        guard response.isSuccessful else {
            throw NetworkError.serverError(
                response.effectiveMessage?.trimmingCharacters(in: .whitespacesAndNewlines)
                    ?? String(localized: "Registration failed. Please try again.")
            )
        }
        return response.data?.agentNo
    }

    func fetchTermsCondition() async throws -> PrivacyData {
        let response: TermsResponse = try await apiClient.send(.termsCondition)
        guard response.status, let data = response.data else {
            throw NetworkError.serverError(
                response.message ?? String(localized: "Failed to load Terms & Conditions.")
            )
        }
        return data
    }

    func fetchPrivacyPolicy() async throws -> PrivacyData {
        let response: PrivacyResponse = try await apiClient.send(.privacy)
        guard response.status, let data = response.data else {
            throw NetworkError.serverError(
                response.message ?? String(localized: "Failed to load privacy policy.")
            )
        }
        return data
    }

    @discardableResult
    func submitContact(_ request: ContactRequest) async throws -> String {
        let response: GenericAPIResponse = try await apiClient.send(.contact(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Failed to send your message. Please try again.")
            )
        }
        return response.message ?? String(localized: "Your message has been sent! Our team will get back to you shortly.")
    }

    // MARK: - Payment

    func createPaymentOrder(amount: Int) async throws -> CreatePaymentOrderData {
        let request = CreatePaymentOrderRequest(transferAmount: amount)
        let response: CreatePaymentOrderResponse = try await apiClient.send(.createPaymentOrder(request))
        guard response.status, let data = response.data else {
            throw NetworkError.serverError(
                response.message ?? String(localized: "Failed to create payment order.")
            )
        }
        return data
    }

    @discardableResult
    func confirmPayment(bodyData: Data, isJSON: Bool = true) async throws -> String? {
        // let accessToken = keychain.read(key: .authToken) ?? "nil"
        // let agentId     = currentUser?.agentId ?? "nil"
        // let requestBody = String(data: bodyData, encoding: .utf8) ?? "nil"
        // print("""
        // [payment_checkout REQUEST]
        //   access_token : \(accessToken)
        //   agent_id     : \(agentId)
        //   body         : \(requestBody)
        // """)
        let response: GenericAPIResponse = try await apiClient.send(.paymentCheckout(body: bodyData, isJSON: isJSON))
        // print("""
        // [payment_checkout RESPONSE]
        //   status       : \(response.status)
        //   message      : \(response.message ?? "nil")
        //   errorCode    : \(response.errorCode.map { "\($0)" } ?? "nil")
        //   errorDesc    : \(response.errorDesc ?? "nil")
        // """)
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Payment confirmation failed.")
            )
        }
        return response.message
    }

    func fetchUploadMoney() async throws -> UploadMoneyData {
        let response: UploadMoneyResponse = try await apiClient.send(.uploadMoney)
        guard response.status, let data = response.data else {
            throw NetworkError.serverError(
                response.message ?? String(localized: "Failed to load upload money data.")
            )
        }
        return data
    }

    func submitUploadMoneyRequest(_ request: UploadMoneyRequest) async throws -> UploadMoneySubmitData {
        let response: UploadMoneySubmitResponse = try await apiClient.send(.uploadMoneyRequest(request))
        guard response.status, let data = response.data else {
            throw NetworkError.serverError(
                response.message ?? String(localized: "Failed to submit money request.")
            )
        }
        return data
    }

    // Returns the OTP code and parsed expiry date for the App Code sheet.
    func getAppCode() async throws -> (code: String?, expiryDate: Date?) {
        guard let agentNo = currentUser?.agentNo else {
            throw NetworkError.serverError(String(localized: "No agent session found."))
        }
        let request = ResendOTPRequest(agentNo: agentNo)
        let response: ResendOTPResponse = try await apiClient.send(.getOTP(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Failed to load App Code.")
            )
        }
        return (response.data?.otp, parseExpiryDate(response.data?.otpExpiry))
    }

    private func parseExpiryDate(_ string: String?) -> Date? {
        guard let string else { return nil }
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone(identifier: "Asia/Kolkata")//formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.date(from: string)
    }

    // MARK: - Profile Edit

    func updateProfile(_ request: UpdateAgentProfileRequest) async throws {
        let response: GenericAPIResponse = try await apiClient.send(.updateAgentProfile(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Failed to update profile.")
            )
        }
    }

    func changePassword(_ request: ChangeAgentPasswordRequest) async throws {
        let response: GenericAPIResponse = try await apiClient.send(.changeAgentPassword(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Failed to change password.")
            )
        }
    }

    func addTraveller(_ request: AgentAddTravellerRequest) async throws {
        let response: GenericAPIResponse = try await apiClient.send(.agentAddTraveller(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Failed to add traveller.")
            )
        }
    }

    func updateTraveller(_ request: AgentUpdateTravellerRequest) async throws {
        let response: GenericAPIResponse = try await apiClient.send(.agentUpdateTraveller(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Failed to update traveller.")
            )
        }
    }

    func deleteTraveller(_ request: AgentDeleteTravellerRequest) async throws {
        let response: GenericAPIResponse = try await apiClient.send(.agentDeleteTraveller(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Failed to delete traveller.")
            )
        }
    }

    func addGST(_ request: AgentAddGSTRequest) async throws {
        let response: GenericAPIResponse = try await apiClient.send(.agentAddGST(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Failed to add GST.")
            )
        }
    }

    func updateGST(_ request: AgentUpdateGSTRequest) async throws {
        let response: GenericAPIResponse = try await apiClient.send(.agentUpdateGST(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Failed to update GST.")
            )
        }
    }

    func deleteGST(_ request: AgentDeleteGSTRequest) async throws {
        let response: GenericAPIResponse = try await apiClient.send(.agentDeleteGST(request))
        guard response.status else {
            throw NetworkError.serverError(
                response.serverMessage ?? String(localized: "Failed to delete GST.")
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

    private static let lastLaunchVersionKey = "com.ftd.lastLaunchVersion"

    // Clears all auth keychain data when the app version changes so the user
    // sees the Splash screen after an update instead of jumping straight to sign-in.
    private func clearKeychainOnVersionChange() {
        let current = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let stored = UserDefaults.standard.string(forKey: Self.lastLaunchVersionKey)
        guard stored != current else { return }
        KeychainKey.allCases
            .filter { $0 != .deviceId }
            .forEach { keychain.delete(key: $0) }
        UserDefaults.standard.set(current, forKey: Self.lastLaunchVersionKey)
    }

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
        if let vendorId = UIDevice.current.identifierForVendor?.uuidString {
            keychain.save(key: .deviceId, value: vendorId)
            return vendorId
        }
        if let existing = keychain.read(key: .deviceId) { return existing }
        let newId = UUID().uuidString
        keychain.save(key: .deviceId, value: newId)
        return newId
    }
}
