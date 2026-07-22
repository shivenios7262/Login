import SwiftUI

@main
struct LOGINApp: App {
    // AuthManager and its dependencies are created once at app launch on the main thread.
    // `let` avoids @State overhead since AuthManager is @Observable and manages its own
    // change notifications internally.
    private let authManager: AuthManager = {
        //KeychainService().delete(key: .appToken)
        let keychain = KeychainService()
//        let keychain = KeychainService()
       // keychain.delete(key: .appToken)
      // print("appToken cleared:", keychain.read(key: .appToken) ?? "nil")
        let apiClient = APIClient(
            httpClient: URLSessionHTTPClient(),
            baseURL: AppConfiguration.apiBaseURL,
            keychain: keychain,
            appCredentials: AppConfiguration.appCredentials
        )
        return AuthManager(apiClient: apiClient, keychain: keychain)
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(authManager)
        }
    }
}
