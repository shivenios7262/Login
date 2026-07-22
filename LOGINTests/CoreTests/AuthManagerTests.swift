import Testing
import Foundation
@testable import LOGIN

@Suite("AuthManager")
@MainActor
struct AuthManagerTests {

    // MARK: - Helpers

    func makeStack() -> (MockHTTPClient, MockKeychainService, APIClient, AuthManager) {
        let http = MockHTTPClient()
        let keychain = MockKeychainService()
        let client = APIClient(
            httpClient: http,
            baseURL: URL(string: "http://test.local")!,
            keychain: keychain,
            appCredentials: AppCredentials(appType: 1, appUser: "test", appPassword: "test", appVersion: "1.0", persistAppToken: false)
        )
        let auth = AuthManager(apiClient: client, keychain: keychain)
        return (http, keychain, client, auth)
    }

    // MARK: - Tests

    @Test("Login succeeds and sets pendingAgentNo, OTP verification completes login")
    func successfulLoginFlow() async throws {
        let (http, keychain, _, auth) = makeStack()

        http.stub(path: "/book/mapp/auth/app_sigin", response: AppSignInResponse(
            errorCode: 0, errorDesc: "", appToken: "app-jwt-123"
        ))
        http.stub(path: "/book/mapp/mapp_b2b/agent_login", response: AgentLoginResponse(
            status: true,
            message: "OTP has been sent to your registered email address.",
            data: AgentLoginData(agentNo: "AGENT001", email: "test@ftd.travel", otpExpiry: nil)
        ))
        http.stub(path: "/book/mapp/mapp_b2b/verify_otp", response: VerifyOTPResponse(
            status: true,
            message: "Login Successful",
            data: VerifyOTPData(
                accessToken: "bearer-456", refreshToken: "refresh-789",
                accessTokenExpiry: nil, refreshTokenExpiry: nil,
                agentId: "7", distId: "11", agentNo: "AGENT001",
                agencyName: "Test Agency", agentEmail: "test@ftd.travel", agentLogo: nil,
                title: nil, firstName: "Test", lastName: "Agent",
                mobileNo: nil, creditBalance: nil, bookingBalance: nil
            )
        ))

        try await auth.login(email: "test@ftd.travel", password: "secret")
        #expect(auth.pendingAgentNo == "AGENT001")
        #expect(!auth.isLoggedIn)

        try await auth.verifyOTP(otp: "123456")
        #expect(auth.isLoggedIn)
        #expect(auth.currentUser?.agentEmail == "test@ftd.travel")
        #expect(keychain.read(key: .authToken) == "bearer-456")
        #expect(keychain.read(key: .refreshToken) == "refresh-789")
    }

    @Test("Wrong credentials throws serverError and leaves session unchanged")
    func wrongCredentialsThrows() async throws {
        let (http, _, _, auth) = makeStack()

        http.stub(path: "/book/mapp/auth/app_sigin", response: AppSignInResponse(
            errorCode: 0, errorDesc: "", appToken: "app-jwt-123"
        ))
        http.stub(path: "/book/mapp/mapp_b2b/agent_login", response: AgentLoginResponse(
            status: false, message: "Invalid credentials", data: nil
        ))

        await #expect(throws: NetworkError.self) {
            try await auth.login(email: "bad@ftd.travel", password: "wrong")
        }

        #expect(!auth.isLoggedIn)
        #expect(auth.pendingAgentNo == nil)
    }

    @Test("Wrong OTP throws serverError and leaves session unchanged")
    func wrongOTPThrows() async throws {
        let (http, _, _, auth) = makeStack()

        http.stub(path: "/book/mapp/auth/app_sigin", response: AppSignInResponse(
            errorCode: 0, errorDesc: "", appToken: "app-jwt-123"
        ))
        http.stub(path: "/book/mapp/mapp_b2b/agent_login", response: AgentLoginResponse(
            status: true,
            message: "OTP has been sent to your registered email address.",
            data: AgentLoginData(agentNo: "AGENT001", email: "test@ftd.travel", otpExpiry: nil)
        ))
        http.stub(path: "/book/mapp/mapp_b2b/verify_otp", response: VerifyOTPResponse(
            status: false,
            message: "Unauthorized Access - Please contact FTD Travel Admin",
            data: nil
        ))

        try await auth.login(email: "test@ftd.travel", password: "secret")

        await #expect(throws: NetworkError.self) {
            try await auth.verifyOTP(otp: "000000")
        }

        #expect(!auth.isLoggedIn)
    }

    @Test("Token refresh stores new access token and updates expiry in Keychain")
    func tokenRefreshStoresNewTokens() async throws {
        let (http, keychain, client, _) = makeStack()

        keychain.save(key: .refreshToken, value: "old-refresh")

        http.stub(path: "/book/mapp/mapp_b2b/refresh_token", response: RefreshTokenResponse(
            status: true,
            message: "Token Refreshed",
            data: RefreshTokenData(accessToken: "new-bearer", expiresIn: 43200)
        ))

        try await client.refreshBearerToken()

        #expect(keychain.read(key: .authToken) == "new-bearer")
        // Refresh token is unchanged — server does not rotate it on refresh.
        #expect(keychain.read(key: .refreshToken) == "old-refresh")
        // New access token expiry should have been persisted.
        #expect(keychain.read(key: .accessTokenExpiry) != nil)
    }

    @Test("Expired access token with valid refresh token silently refreshes on relaunch")
    func expiredAccessTokenRefreshesOnRelaunch() async throws {
        let http = MockHTTPClient()
        let keychain = MockKeychainService()

        // Seed keychain BEFORE AuthManager init so restoreSession() picks up isLoggedIn = true.
        keychain.save(key: .authToken, value: "old-bearer")
        keychain.save(key: .accessTokenExpiry, value: "2000-01-01 00:00:00")  // definitely expired
        keychain.save(key: .refreshToken, value: "valid-refresh")
        keychain.save(key: .refreshTokenExpiry, value: "2099-12-31 23:59:59") // far future

        let client = APIClient(
            httpClient: http,
            baseURL: URL(string: "http://test.local")!,
            keychain: keychain,
            appCredentials: AppCredentials(appType: 1, appUser: "t", appPassword: "t", appVersion: "1.0", persistAppToken: false)
        )
        let auth = AuthManager(apiClient: client, keychain: keychain)

        http.stub(path: "/book/mapp/mapp_b2b/refresh_token", response: RefreshTokenResponse(
            status: true,
            message: "Token Refreshed",
            data: RefreshTokenData(accessToken: "refreshed-bearer", expiresIn: 43200)
        ))

        await auth.checkAndRefreshTokenIfNeeded()

        #expect(keychain.read(key: .authToken) == "refreshed-bearer")
        #expect(auth.isLoggedIn)
    }

    @Test("Expired refresh token logs out automatically on relaunch")
    func expiredRefreshTokenLogsOut() async throws {
        let http = MockHTTPClient()
        let keychain = MockKeychainService()

        keychain.save(key: .authToken, value: "old-bearer")
        keychain.save(key: .accessTokenExpiry, value: "2000-01-01 00:00:00")
        keychain.save(key: .refreshToken, value: "expired-refresh")
        keychain.save(key: .refreshTokenExpiry, value: "2000-01-01 00:00:00")

        let client = APIClient(
            httpClient: http,
            baseURL: URL(string: "http://test.local")!,
            keychain: keychain,
            appCredentials: AppCredentials(appType: 1, appUser: "t", appPassword: "t", appVersion: "1.0", persistAppToken: false)
        )
        let auth = AuthManager(apiClient: client, keychain: keychain)

        await auth.checkAndRefreshTokenIfNeeded()

        #expect(!auth.isLoggedIn)
        #expect(keychain.read(key: .authToken) == nil)
        #expect(keychain.read(key: .accessTokenExpiry) == nil)
    }

    @Test("Session is restored from Keychain on app restart")
    func sessionPersistenceAcrossRestarts() {
        let http = MockHTTPClient()
        let keychain = MockKeychainService()
        keychain.save(key: .authToken, value: "persisted-token")

        let client = APIClient(
            httpClient: http,
            baseURL: URL(string: "http://test.local")!,
            keychain: keychain,
            appCredentials: AppCredentials(appType: 1, appUser: "t", appPassword: "t", appVersion: "1.0", persistAppToken: false)
        )
        let freshAuth = AuthManager(apiClient: client, keychain: keychain)

        #expect(freshAuth.isLoggedIn)
    }

    @Test("Logout clears auth data but keeps app token")
    func logoutKeepsAppToken() async throws {
        let (http, keychain, _, auth) = makeStack()

        http.stub(path: "/book/mapp/auth/app_sigin", response: AppSignInResponse(
            errorCode: 0, errorDesc: "", appToken: "app-jwt-123"
        ))
        http.stub(path: "/book/mapp/mapp_b2b/agent_login", response: AgentLoginResponse(
            status: true,
            message: "OTP has been sent to your registered email address.",
            data: AgentLoginData(agentNo: "AGENT001", email: "test@ftd.travel", otpExpiry: nil)
        ))
        http.stub(path: "/book/mapp/mapp_b2b/verify_otp", response: VerifyOTPResponse(
            status: true,
            message: "Login Successful",
            data: VerifyOTPData(
                accessToken: "bearer-456", refreshToken: "refresh-789",
                accessTokenExpiry: nil, refreshTokenExpiry: nil,
                agentId: nil, distId: nil, agentNo: "AGENT001",
                agencyName: nil, agentEmail: "t@t.com", agentLogo: nil,
                title: nil, firstName: "Test", lastName: nil,
                mobileNo: nil, creditBalance: nil, bookingBalance: nil
            )
        ))

        try await auth.login(email: "t@t.com", password: "pass")
        try await auth.verifyOTP(otp: "123456")
        keychain.save(key: .appToken, value: "app-jwt-123")

        auth.logout()

        #expect(!auth.isLoggedIn)
        #expect(auth.currentUser == nil)
        #expect(keychain.read(key: .authToken) == nil)
        #expect(keychain.read(key: .userData) == nil)
        #expect(keychain.read(key: .appToken) == "app-jwt-123")
    }
}
