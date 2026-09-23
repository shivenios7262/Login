import Foundation

// Single-binary environment detection.
//
// Archive once with the Release scheme. The same .ipa covers both TestFlight
// and App Store — all env values (URL, credentials, timezone) are chosen at runtime:
//
//   Debug (Xcode/simulator) → dev values from Debug.xcconfig
//   TestFlight              → dev/staging values (APP_STAGING_* keys) from Release.xcconfig
//   App Store               → production values (APP_* keys) from Release.xcconfig
//
// Detection relies on the StoreKit receipt filename Apple embeds at runtime:
//   "sandboxReceipt" → TestFlight   "receipt" → App Store   absent → Xcode/simulator

enum AppEnvironment: String, Sendable {
    case debug
    case staging
    case production

    var isDebugLike: Bool { self != .production }
}

enum AppConfiguration {
    // True when running a TestFlight build (sandboxReceipt) or a simulator/Xcode
    // install (no receipt at all). False only for an App Store install.
    private static var isTestFlightOrDev: Bool {
        let receipt = Bundle.main.appStoreReceiptURL?.lastPathComponent
        return receipt != "receipt"
    }

    static var environment: AppEnvironment {
        #if DEBUG
        return .debug
        #else
        return isTestFlightOrDev ? .staging : .production
        #endif
    }

    static var apiBaseURL: URL {
        let key: String
        #if DEBUG
        key = "APP_API_BASE_URL"
        #else
        key = isTestFlightOrDev ? "APP_API_STAGING_URL" : "APP_API_BASE_URL"
        #endif
        guard
            let string = Bundle.main.infoDictionary?[key] as? String,
            let url = URL(string: string)
        else {
            fatalError("\(key) missing — check xcconfig files. See Config/Release.xcconfig.")
        }
        return url
    }

    static var otpExpiryTimeZone: TimeZone {
        #if DEBUG
        let key = "APP_OTP_TIMEZONE"
        #else
        let key = isTestFlightOrDev ? "APP_STAGING_OTP_TIMEZONE" : "APP_OTP_TIMEZONE"
        #endif
        let id = Bundle.main.infoDictionary?[key] as? String ?? "UTC"
        return TimeZone(identifier: id) ?? .gmt
    }

    static var appCredentials: AppCredentials {
        let dict = Bundle.main.infoDictionary ?? [:]
        #if DEBUG
        let userKey = "APP_USER"
        let passwordKey = "APP_PASSWORD"
        let versionKey = "APP_VERSION"
        #else
        let isTF = isTestFlightOrDev
        let userKey = isTF ? "APP_STAGING_USER" : "APP_USER"
        let passwordKey = isTF ? "APP_STAGING_PASSWORD" : "APP_PASSWORD"
        let versionKey = isTF ? "APP_STAGING_VERSION" : "APP_VERSION"
        #endif
        return AppCredentials(
            appType: Int(dict["APP_TYPE"] as? String ?? "") ?? 1,
            appUser: dict[userKey] as? String ?? "",
            appPassword: dict[passwordKey] as? String ?? "",
            appVersion: dict[versionKey] as? String ?? "1.0",
            // true  → app token fetched once, persisted in keychain, Splash skipped on relaunch
            // false → app token fetched on every launch, never cached, Splash always shown
            persistAppToken: true
        )
    }
}

struct AppCredentials: Sendable {
    let appType: Int
    let appUser: String
    let appPassword: String
    let appVersion: String
    let persistAppToken: Bool
}
