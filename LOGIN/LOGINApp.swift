import SwiftUI

@main
struct LOGINApp: App {
    // AuthManager and AppRouter are created once at app launch on the main thread.
    // `let` avoids @State overhead since both types are @Observable.
    private let authManager: AuthManager = {
        // Uncomment to wipe stored tokens and test the full first-launch flow:
        // KeychainService().delete(key: .appToken)
        // KeychainService().delete(key: .accessToken)
          let keychain   = KeychainService()
//        keychain.delete(key: .userData)
//       keychain.delete(key: .deviceId)
//        keychain.delete(key: .appToken)
////         print("appToken cleared:", keychain.read(key: .appToken) ?? "nil")
        let apiClient  = APIClient(
            httpClient:     URLSessionHTTPClient(),
            baseURL:        AppConfiguration.apiBaseURL,
            keychain:       keychain,
            appCredentials: AppConfiguration.appCredentials
        )
        return AuthManager(apiClient: apiClient, keychain: keychain)
    }()

    private let appRouter = AppRouter()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authManager)
                .environment(appRouter)
        }
    }
}


