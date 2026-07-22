import Foundation

enum APIEndpoint: Sendable {
    case appSignIn(AppSignInRequest)
    case agentLogin(AgentLoginRequest)
    case verifyOTP(VerifyOTPRequest)
    case resendOTP(ResendOTPRequest)
    case refreshToken(RefreshTokenRequest)

    // nonisolated: encoding is pure data transformation, not UI work.
    nonisolated func makeRequest() throws -> APIRequest {
        switch self {
        case .appSignIn(let body):
            return APIRequest(
                path: "/book/mapp/auth/app_sigin",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: false,
                requiresBearerToken: false
            )
        case .agentLogin(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_login",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: false
            )
        case .verifyOTP(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/verify_otp",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: false
            )
        case .resendOTP(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/resend_otp",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: false
            )
        case .refreshToken(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/refresh_token",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: false
            )
        }
    }
}
