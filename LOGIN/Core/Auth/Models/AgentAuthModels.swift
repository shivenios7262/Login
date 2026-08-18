import Foundation

// nonisolated Codable implementations required — see AppTokenModels.swift for explanation.

// MARK: - Agent Login

struct AgentLoginRequest: Codable, Sendable {
    let email: String
    let password: String
    let deviceId: String

    enum CodingKeys: String, CodingKey {
        case email, password
        case deviceId = "device_id"
    }

    nonisolated init(email: String, password: String, deviceId: String) {
        self.email = email
        self.password = password
        self.deviceId = deviceId
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        email = try c.decode(String.self, forKey: .email)
        password = try c.decode(String.self, forKey: .password)
        deviceId = try c.decode(String.self, forKey: .deviceId)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(email, forKey: .email)
        try c.encode(password, forKey: .password)
        try c.encode(deviceId, forKey: .deviceId)
    }
}

// Verified response shape:
// Success: { "status": true, "message": "OTP has been sent...", "data": { "agent_no": "...", "email": "...", "otp_expiry": "..." } }
// Failure: { "status": false, "message": "Unauthorized Access..." }
struct AgentLoginData: Codable, Sendable {
    let agentNo: String
    let email: String?
    let otpExpiry: String?

    enum CodingKeys: String, CodingKey {
        case email
        case agentNo   = "agent_no"
        case otpExpiry = "otp_expiry"
    }

    nonisolated init(agentNo: String, email: String?, otpExpiry: String?) {
        self.agentNo = agentNo
        self.email = email
        self.otpExpiry = otpExpiry
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        agentNo   = try c.decode(String.self, forKey: .agentNo)
        email     = try c.decodeIfPresent(String.self, forKey: .email)
        otpExpiry = try c.decodeIfPresent(String.self, forKey: .otpExpiry)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(agentNo,            forKey: .agentNo)
        try c.encodeIfPresent(email,     forKey: .email)
        try c.encodeIfPresent(otpExpiry, forKey: .otpExpiry)
    }
}

struct AgentLoginResponse: Codable, Sendable {
    let status: Bool
    let message: String?
    let errorCode: Int?
    let errorDesc: String?
    let data: AgentLoginData?

    // API sends "message" on success, "ErrorDesc"/"ErrorCode" on failure.
    var serverMessage: String? { message ?? errorDesc }

    enum CodingKeys: String, CodingKey {
        case status, message, data
        case errorCode = "ErrorCode"
        case errorDesc = "ErrorDesc"
    }

    nonisolated init(status: Bool, message: String?, errorCode: Int?, errorDesc: String?, data: AgentLoginData?) {
        self.status    = status
        self.message   = message
        self.errorCode = errorCode
        self.errorDesc = errorDesc
        self.data      = data
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        status    = try c.decode(Bool.self, forKey: .status)
        message   = try c.decodeIfPresent(String.self,        forKey: .message)
        errorCode = try c.decodeIfPresent(Int.self,           forKey: .errorCode)
        errorDesc = try c.decodeIfPresent(String.self,        forKey: .errorDesc)
        data      = try c.decodeIfPresent(AgentLoginData.self, forKey: .data)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(message,   forKey: .message)
        try c.encodeIfPresent(errorCode, forKey: .errorCode)
        try c.encodeIfPresent(errorDesc, forKey: .errorDesc)
        try c.encodeIfPresent(data,      forKey: .data)
    }
}

// MARK: - Verify OTP

// Verified response shape (success):
// { "status": true, "message": "Login Successful", "data": { "access_token": "...", "refresh_token": "...", agent_no, agent_email, ... } }
// Failure: { "status": false, "message": "..." }
struct VerifyOTPData: Codable, Sendable {
    let accessToken: String
    let refreshToken: String
    let accessTokenExpiry: String?
    let refreshTokenExpiry: String?
    let agentId: String?
    let distId: String?
    let agentNo: String?
    let agencyName: String?
    let agentEmail: String?
    let agentLogo: String?
    let title: String?
    let firstName: String?
    let lastName: String?
    let mobileNo: String?
    let creditBalance: String?
    let bookingBalance: String?
    let registerDate: String?
    let lastLogin: String?
    let lastBooking: String?

    enum CodingKeys: String, CodingKey {
        case title
        case accessToken        = "access_token"
        case refreshToken       = "refresh_token"
        case accessTokenExpiry  = "access_token_expiry"
        case refreshTokenExpiry = "refresh_token_expiry"
        case agentId            = "agent_id"
        case distId             = "dist_id"
        case agentNo            = "agent_no"
        case agencyName         = "agency_name"
        case agentEmail         = "agent_email"
        case agentLogo          = "agent_logo"
        case firstName          = "first_name"
        case lastName           = "last_name"
        case mobileNo           = "mobile_no"
        case creditBalance      = "creditbalance"
        case bookingBalance     = "bookingbalance"
        case registerDate       = "register_date"
        case lastLogin          = "last_login"
        case lastBooking        = "last_booking"
    }

    nonisolated init(
        accessToken: String, refreshToken: String,
        accessTokenExpiry: String?, refreshTokenExpiry: String?,
        agentId: String?, distId: String?, agentNo: String?,
        agencyName: String?, agentEmail: String?, agentLogo: String?,
        title: String?, firstName: String?, lastName: String?,
        mobileNo: String?, creditBalance: String?, bookingBalance: String?,
        registerDate: String? = nil, lastLogin: String? = nil, lastBooking: String? = nil
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.accessTokenExpiry = accessTokenExpiry
        self.refreshTokenExpiry = refreshTokenExpiry
        self.agentId = agentId
        self.distId = distId
        self.agentNo = agentNo
        self.agencyName = agencyName
        self.agentEmail = agentEmail
        self.agentLogo = agentLogo
        self.title = title
        self.firstName = firstName
        self.lastName = lastName
        self.mobileNo = mobileNo
        self.creditBalance = creditBalance
        self.bookingBalance = bookingBalance
        self.registerDate = registerDate
        self.lastLogin = lastLogin
        self.lastBooking = lastBooking
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        accessToken        = try c.decode(String.self, forKey: .accessToken)
        refreshToken       = try c.decode(String.self, forKey: .refreshToken)
        accessTokenExpiry  = try c.decodeIfPresent(String.self, forKey: .accessTokenExpiry)
        refreshTokenExpiry = try c.decodeIfPresent(String.self, forKey: .refreshTokenExpiry)
        agentId            = try c.decodeIfPresent(String.self, forKey: .agentId)
        distId             = try c.decodeIfPresent(String.self, forKey: .distId)
        agentNo            = try c.decodeIfPresent(String.self, forKey: .agentNo)
        agencyName         = try c.decodeIfPresent(String.self, forKey: .agencyName)
        agentEmail         = try c.decodeIfPresent(String.self, forKey: .agentEmail)
        agentLogo          = try c.decodeIfPresent(String.self, forKey: .agentLogo)
        title              = try c.decodeIfPresent(String.self, forKey: .title)
        firstName          = try c.decodeIfPresent(String.self, forKey: .firstName)
        lastName           = try c.decodeIfPresent(String.self, forKey: .lastName)
        mobileNo           = try c.decodeIfPresent(String.self, forKey: .mobileNo)
        creditBalance      = (try? c.decodeIfPresent(String.self, forKey: .creditBalance))
            ?? (try? c.decodeIfPresent(Double.self, forKey: .creditBalance)).map { String($0) }
        bookingBalance     = (try? c.decodeIfPresent(String.self, forKey: .bookingBalance))
            ?? (try? c.decodeIfPresent(Double.self, forKey: .bookingBalance)).map { String($0) }
        registerDate       = try c.decodeIfPresent(String.self, forKey: .registerDate)
        lastLogin          = try c.decodeIfPresent(String.self, forKey: .lastLogin)
        lastBooking        = try c.decodeIfPresent(String.self, forKey: .lastBooking)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(accessToken,                 forKey: .accessToken)
        try c.encode(refreshToken,               forKey: .refreshToken)
        try c.encodeIfPresent(accessTokenExpiry,  forKey: .accessTokenExpiry)
        try c.encodeIfPresent(refreshTokenExpiry, forKey: .refreshTokenExpiry)
        try c.encodeIfPresent(agentId,           forKey: .agentId)
        try c.encodeIfPresent(distId,            forKey: .distId)
        try c.encodeIfPresent(agentNo,           forKey: .agentNo)
        try c.encodeIfPresent(agencyName,        forKey: .agencyName)
        try c.encodeIfPresent(agentEmail,        forKey: .agentEmail)
        try c.encodeIfPresent(agentLogo,         forKey: .agentLogo)
        try c.encodeIfPresent(title,             forKey: .title)
        try c.encodeIfPresent(firstName,         forKey: .firstName)
        try c.encodeIfPresent(lastName,          forKey: .lastName)
        try c.encodeIfPresent(mobileNo,          forKey: .mobileNo)
        try c.encodeIfPresent(creditBalance,     forKey: .creditBalance)
        try c.encodeIfPresent(bookingBalance,    forKey: .bookingBalance)
        try c.encodeIfPresent(registerDate,      forKey: .registerDate)
        try c.encodeIfPresent(lastLogin,         forKey: .lastLogin)
        try c.encodeIfPresent(lastBooking,       forKey: .lastBooking)
    }

    var user: User {
        User(
            agentId: agentId, distId: distId, agentNo: agentNo,
            agencyName: agencyName, agentEmail: agentEmail, agentLogo: agentLogo,
            title: title, firstName: firstName, lastName: lastName,
            mobileNo: mobileNo, creditBalance: creditBalance, bookingBalance: bookingBalance,
            registerDate: registerDate, lastLogin: lastLogin, lastBooking: lastBooking
        )
    }
}

struct VerifyOTPRequest: Codable, Sendable {
    let agentNo: String
    let otp: String
    let deviceId: String
    let screenSize: String
    let deviceModel: String
    let osVersion: String

    enum CodingKeys: String, CodingKey {
        case otp
        case agentNo    = "agent_no"
        case deviceId   = "device_id"
        case screenSize = "screen_size"
        case deviceModel = "device_model"
        case osVersion  = "os_version"
    }

    nonisolated init(agentNo: String, otp: String, deviceId: String, screenSize: String, deviceModel: String, osVersion: String) {
        self.agentNo = agentNo
        self.otp = otp
        self.deviceId = deviceId
        self.screenSize = screenSize
        self.deviceModel = deviceModel
        self.osVersion = osVersion
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        agentNo     = try c.decode(String.self, forKey: .agentNo)
        otp         = try c.decode(String.self, forKey: .otp)
        deviceId    = try c.decode(String.self, forKey: .deviceId)
        screenSize  = try c.decode(String.self, forKey: .screenSize)
        deviceModel = try c.decode(String.self, forKey: .deviceModel)
        osVersion   = try c.decode(String.self, forKey: .osVersion)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(agentNo,     forKey: .agentNo)
        try c.encode(otp,         forKey: .otp)
        try c.encode(deviceId,    forKey: .deviceId)
        try c.encode(screenSize,  forKey: .screenSize)
        try c.encode(deviceModel, forKey: .deviceModel)
        try c.encode(osVersion,   forKey: .osVersion)
    }
}

struct VerifyOTPResponse: Codable, Sendable {
    let status: Bool
    let message: String?
    let errorCode: Int?
    let errorDesc: String?
    let data: VerifyOTPData?

    var serverMessage: String? { message ?? errorDesc }

    enum CodingKeys: String, CodingKey {
        case status, message, data
        case errorCode = "ErrorCode"
        case errorDesc = "ErrorDesc"
    }

    nonisolated init(status: Bool, message: String?, errorCode: Int?, errorDesc: String?, data: VerifyOTPData?) {
        self.status    = status
        self.message   = message
        self.errorCode = errorCode
        self.errorDesc = errorDesc
        self.data      = data
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        status    = try c.decode(Bool.self, forKey: .status)
        message   = try c.decodeIfPresent(String.self,       forKey: .message)
        errorCode = try c.decodeIfPresent(Int.self,          forKey: .errorCode)
        errorDesc = try c.decodeIfPresent(String.self,       forKey: .errorDesc)
        data      = try c.decodeIfPresent(VerifyOTPData.self, forKey: .data)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(message,   forKey: .message)
        try c.encodeIfPresent(errorCode, forKey: .errorCode)
        try c.encodeIfPresent(errorDesc, forKey: .errorDesc)
        try c.encodeIfPresent(data,      forKey: .data)
    }
}

// MARK: - Resend OTP

struct ResendOTPRequest: Codable, Sendable {
    let agentNo: String

    enum CodingKeys: String, CodingKey {
        case agentNo = "agent_no"
    }

    nonisolated init(agentNo: String) { self.agentNo = agentNo }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        agentNo = try c.decode(String.self, forKey: .agentNo)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(agentNo, forKey: .agentNo)
    }
}

// Verified response shape:
// { "status": true, "message": "OTP resend...", "data": { "agent_no": "...", "email": "...", "otp_expiry": "..." } }
struct ResendOTPResponse: Codable, Sendable {
    let status: Bool
    let message: String?
    let errorCode: Int?
    let errorDesc: String?
    let data: AgentLoginData?

    var serverMessage: String? { message ?? errorDesc }

    enum CodingKeys: String, CodingKey {
        case status, message, data
        case errorCode = "ErrorCode"
        case errorDesc = "ErrorDesc"
    }

    nonisolated init(status: Bool, message: String?, errorCode: Int?, errorDesc: String?, data: AgentLoginData?) {
        self.status    = status
        self.message   = message
        self.errorCode = errorCode
        self.errorDesc = errorDesc
        self.data      = data
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        status    = try c.decode(Bool.self, forKey: .status)
        message   = try c.decodeIfPresent(String.self,        forKey: .message)
        errorCode = try c.decodeIfPresent(Int.self,           forKey: .errorCode)
        errorDesc = try c.decodeIfPresent(String.self,        forKey: .errorDesc)
        data      = try c.decodeIfPresent(AgentLoginData.self, forKey: .data)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(message,   forKey: .message)
        try c.encodeIfPresent(errorCode, forKey: .errorCode)
        try c.encodeIfPresent(errorDesc, forKey: .errorDesc)
        try c.encodeIfPresent(data,      forKey: .data)
    }
}

struct RefreshTokenRequest: Codable, Sendable {
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }

    nonisolated init(refreshToken: String) {
        self.refreshToken = refreshToken
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        refreshToken = try c.decode(String.self, forKey: .refreshToken)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(refreshToken, forKey: .refreshToken)
    }
}

// Verified response shape:
// Success: { "status": true, "message": "Token Refreshed", "data": { "access_token": "...", "expires_in": 43200 } }
// Failure: { "status": false, "message": "..." }
struct RefreshTokenData: Codable, Sendable {
    let accessToken: String
    let expiresIn: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case expiresIn   = "expires_in"
    }

    nonisolated init(accessToken: String, expiresIn: Int) {
        self.accessToken = accessToken
        self.expiresIn = expiresIn
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try c.decode(String.self, forKey: .accessToken)
        expiresIn   = try c.decode(Int.self,    forKey: .expiresIn)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(accessToken, forKey: .accessToken)
        try c.encode(expiresIn,   forKey: .expiresIn)
    }
}

struct RefreshTokenResponse: Codable, Sendable {
    let status: Bool
    let message: String?
    let errorCode: Int?
    let errorDesc: String?
    let data: RefreshTokenData?

    var serverMessage: String? { message ?? errorDesc }

    enum CodingKeys: String, CodingKey {
        case status, message, data
        case errorCode = "ErrorCode"
        case errorDesc = "ErrorDesc"
    }

    nonisolated init(status: Bool, message: String?, errorCode: Int?, errorDesc: String?, data: RefreshTokenData?) {
        self.status    = status
        self.message   = message
        self.errorCode = errorCode
        self.errorDesc = errorDesc
        self.data      = data
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        status    = try c.decode(Bool.self, forKey: .status)
        message   = try c.decodeIfPresent(String.self,           forKey: .message)
        errorCode = try c.decodeIfPresent(Int.self,              forKey: .errorCode)
        errorDesc = try c.decodeIfPresent(String.self,           forKey: .errorDesc)
        data      = try c.decodeIfPresent(RefreshTokenData.self, forKey: .data)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(message,   forKey: .message)
        try c.encodeIfPresent(errorCode, forKey: .errorCode)
        try c.encodeIfPresent(errorDesc, forKey: .errorDesc)
        try c.encodeIfPresent(data,      forKey: .data)
    }
}
