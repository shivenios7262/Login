import SwiftUI

struct RootView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var showAuth = false

    var body: some View {
        if authManager.isLoggedIn {
            // --- Route: toggle comment to switch home screen designs ---
            // HomeView(authManager: authManager)          // Legacy home screen
            FTDHomeView(authManager: authManager)          // New FTD redesign
        } else if authManager.hasAppToken {
            // App token already acquired on a prior launch — skip Splash and go straight to auth.
            NavigationStack {
                AuthContainerView()
                    .navigationBarBackButtonHidden(true)
            }
        } else {
            NavigationStack {
                SplashView {
                    try await authManager.fetchAppToken()
                    showAuth = true
                }
                .navigationDestination(isPresented: $showAuth) {
                    AuthContainerView()
                }
            }
        }
    }
}
