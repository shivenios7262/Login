import Foundation

// nonisolated Codable implementations are required because SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor
// would otherwise make the synthesized init(from:)/encode(to:) @MainActor, preventing their use
// from within the APIClient actor.

struct AppSignInRequest: Codable, Sendable {
    let appType: Int
    let appUser: String
    let appPassword: String
    let appVersion: String
    let deviceID: String

    enum CodingKeys: String, CodingKey {
        case appType, appUser, appPassword, appVersion, deviceID
    }

    nonisolated init(appType: Int, appUser: String, appPassword: String, appVersion: String, deviceID: String) {
        self.appType = appType
        self.appUser = appUser
        self.appPassword = appPassword
        self.appVersion = appVersion
        self.deviceID = deviceID
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        appType = try c.decode(Int.self, forKey: .appType)
        appUser = try c.decode(String.self, forKey: .appUser)
        appPassword = try c.decode(String.self, forKey: .appPassword)
        appVersion = try c.decode(String.self, forKey: .appVersion)
        deviceID = try c.decode(String.self, forKey: .deviceID)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(appType, forKey: .appType)
        try c.encode(appUser, forKey: .appUser)
        try c.encode(appPassword, forKey: .appPassword)
        try c.encode(appVersion, forKey: .appVersion)
        try c.encode(deviceID, forKey: .deviceID)
    }
}

// Verified against real API response:
// { "ErrorCode": 0, "ErrorDesc": "", "appToken": "<jwt>" }
struct AppSignInResponse: Codable, Sendable {
    let errorCode: Int
    let errorDesc: String
    let appToken: String?

    var status: Bool { errorCode == 0 }
    var message: String? { errorDesc.isEmpty ? nil : errorDesc }

    enum CodingKeys: String, CodingKey {
        case errorCode = "ErrorCode"
        case errorDesc = "ErrorDesc"
        case appToken = "appToken"
    }

    nonisolated init(errorCode: Int, errorDesc: String, appToken: String?) {
        self.errorCode = errorCode
        self.errorDesc = errorDesc
        self.appToken = appToken
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        errorCode = try c.decode(Int.self, forKey: .errorCode)
        errorDesc = try c.decode(String.self, forKey: .errorDesc)
        appToken = try c.decodeIfPresent(String.self, forKey: .appToken)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(errorCode, forKey: .errorCode)
        try c.encode(errorDesc, forKey: .errorDesc)
        try c.encodeIfPresent(appToken, forKey: .appToken)
    }
}
