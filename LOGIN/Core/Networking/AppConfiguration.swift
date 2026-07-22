import Foundation

// Reads build-time values injected from Config/Debug.xcconfig or Config/Release.xcconfig
// via Info.plist substitution variables.
//
// Xcode setup (one-time, per developer):
//  1. Project → Info → Configurations: assign Debug.xcconfig to Debug, Release.xcconfig to Release.
//  2. Add a custom Info.plist (LOGIN/Info.plist) with keys:
//       APP_API_BASE_URL  → $(APP_API_BASE_URL)
//       APP_TYPE          → $(APP_TYPE)
//       APP_USER          → $(APP_USER)
//       APP_PASSWORD      → $(APP_PASSWORD)
//       APP_VERSION       → $(APP_VERSION)
//  3. Set INFOPLIST_FILE = LOGIN/Info.plist in Build Settings.
//  4. Gitignore Config/Debug.xcconfig and Config/Release.xcconfig to keep secrets out of VCS.
enum AppConfiguration {
    static var apiBaseURL: URL {
        guard
            let string = Bundle.main.infoDictionary?["APP_API_BASE_URL"] as? String,
            let url = URL(string: string)
        else {
            fatalError("APP_API_BASE_URL missing — assign xcconfig files to build configurations. See Config/Debug.xcconfig.")
        }
        return url
    }

    static var appCredentials: AppCredentials {
        let dict = Bundle.main.infoDictionary ?? [:]
        return AppCredentials(
            appType: Int(dict["APP_TYPE"] as? String ?? "") ?? 1,
            appUser: dict["APP_USER"] as? String ?? "",
            appPassword: dict["APP_PASSWORD"] as? String ?? "",
            appVersion: dict["APP_VERSION"] as? String ?? "1.0",
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
