import Foundation

actor APIClient {
    // nonisolated let: these are immutable after init and Sendable, so safe to read from any context.
    nonisolated private let httpClient: any HTTPClientProtocol
    nonisolated private let baseURL: URL
    nonisolated private let keychain: any KeychainServiceProtocol
    nonisolated private let appCredentials: AppCredentials
    private var appToken: String?

    init(
        httpClient: any HTTPClientProtocol,
        baseURL: URL,
        keychain: any KeychainServiceProtocol,
        appCredentials: AppCredentials
    ) {
        self.httpClient = httpClient
        self.baseURL = baseURL
        self.keychain = keychain
        self.appCredentials = appCredentials
        // App token is intentionally not restored from Keychain — it may have expired
        // between sessions. A fresh one is fetched on the first request that needs it.
    }

    // MARK: - Public

    func send<T: Decodable & Sendable>(_ endpoint: APIEndpoint) async throws -> T {
        let apiRequest = try endpoint.makeRequest()

        if apiRequest.requiresAppToken {
            try await ensureAppToken()
        }
        if apiRequest.requiresBearerToken {
            // Proactively check expiry and refresh before the request hits the wire.
            try await ensureValidAccessToken()
        }

        let urlRequest = buildURLRequest(from: apiRequest)

        do {
            return try await httpClient.send(urlRequest)
        } catch NetworkError.unauthorized where apiRequest.requiresBearerToken {
            // Fallback: server rejected token despite local check — refresh and retry once.
            try await refreshBearerToken()
            let retried = buildURLRequest(from: apiRequest)
            return try await httpClient.send(retried)
        } catch NetworkError.unauthorized where apiRequest.requiresAppToken {
            // App token expired mid-session — discard and fetch a new one, then retry once.
            appToken = nil
            keychain.delete(key: .appToken)
            try await fetchAppToken()
            let retried = buildURLRequest(from: apiRequest)
            return try await httpClient.send(retried)
        }
    }

    // MARK: - App Token

    func prepareAppToken() async throws {
        try await ensureAppToken()
    }

    private func ensureAppToken() async throws {
        guard appToken == nil else { return }
        // When caching is enabled, restore the persisted token instead of hitting the API again.
        if appCredentials.persistAppToken, let cached = keychain.read(key: .appToken) {
            appToken = cached
            return
        }
        try await fetchAppToken()
    }

    private func fetchAppToken() async throws {
        let deviceID = keychain.read(key: .deviceId) ?? UUID().uuidString
        let request = AppSignInRequest(
            appType: appCredentials.appType,
            appUser: appCredentials.appUser,
            appPassword: appCredentials.appPassword,
            appVersion: appCredentials.appVersion,
            deviceID: deviceID
        )
        let urlRequest = buildURLRequest(from: try APIEndpoint.appSignIn(request).makeRequest())
        let response: AppSignInResponse = try await httpClient.send(urlRequest)
        guard response.status, let token = response.appToken else {
            throw NetworkError.serverError(
                response.message ?? String(localized: "App authentication failed")
            )
        }
        appToken = token
        if appCredentials.persistAppToken {
            keychain.save(key: .appToken, value: token)
        }
    }

    // MARK: - Bearer Token Expiry

    // Called by AuthManager on relaunch and by send() before every authenticated request.
    func ensureValidAccessToken() async throws {
        let now = Date()

        // If no expiry was ever stored (pre-feature install), skip proactive check.
        guard let expiryString = keychain.read(key: .accessTokenExpiry),
              let expiry = parseISTDate(expiryString) else { return }

        // 30-second buffer so we don't send a token that expires mid-flight.
        if now < expiry.addingTimeInterval(-30) { return }

        // Access token expired — check whether refresh token is still valid.
        guard let refreshExpiryString = keychain.read(key: .refreshTokenExpiry),
              let refreshExpiry = parseISTDate(refreshExpiryString),
              now < refreshExpiry else {
            throw NetworkError.sessionExpired
        }

        try await refreshBearerToken()
    }

    // MARK: - Bearer Token Refresh

    // Internal (not private) so unit tests can exercise the refresh path directly.
    func refreshBearerToken() async throws {
        guard let storedRefreshToken = keychain.read(key: .refreshToken) else {
            throw NetworkError.sessionExpired
        }
        let request = RefreshTokenRequest(refreshToken: storedRefreshToken)
        let urlRequest = buildURLRequest(from: try APIEndpoint.refreshToken(request).makeRequest())
        let response: RefreshTokenResponse = try await httpClient.send(urlRequest)
        guard response.status, let data = response.data else {
            throw NetworkError.sessionExpired
        }
        keychain.save(key: .authToken, value: data.accessToken)
        // Compute new expiry from seconds offset and persist as IST string.
        let newExpiry = Date().addingTimeInterval(TimeInterval(data.expiresIn))
        keychain.save(key: .accessTokenExpiry, value: formatISTDate(newExpiry))
    }

    // MARK: - IST Date Helpers

    private func parseISTDate(_ string: String) -> Date? {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return f.date(from: string)
    }

    private func formatISTDate(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        f.timeZone = TimeZone(identifier: "Asia/Kolkata")
        return f.string(from: date)
    }

    // MARK: - URLRequest Building

    private func buildURLRequest(from apiRequest: APIRequest) -> URLRequest {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false)!
        components.path = apiRequest.path
        let url = components.url!
        var request = URLRequest(url: url)
        request.httpMethod = apiRequest.method.rawValue
        request.setValue(apiRequest.contentType, forHTTPHeaderField: "Content-Type")

        if apiRequest.requiresAppToken, let token = appToken {
            request.setValue(token, forHTTPHeaderField: "App-Token")
        }
        if apiRequest.requiresBearerToken, let token = keychain.read(key: .authToken) {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = apiRequest.body
        return request
    }
}
