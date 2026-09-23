import SwiftUI

struct RootView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AppRouter.self)   private var router

    // Decouples the home transition from isLoggedIn so the VerifyOTP sheet
    // can finish its dismiss animation before FTDHomeView is shown.
    @State private var homeReady = false

    var body: some View {
        Group {
            if homeReady {
                FTDHomeView(authManager: authManager)
                    .transition(.opacity)
            } else {
                authFlow
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: homeReady)
        .onAppear {
            // Restore home directly if session is already active on launch
            if authManager.isLoggedIn { homeReady = true }
        }
        .onChange(of: authManager.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                if router.authSheet != nil {
                    // Sheet is up — dismiss it; homeReady is set in onDismiss
                    // so FTDHomeView cross-fades in after the sheet slides away.
                    router.authSheet = nil
                } else {
                    homeReady = true
                }
            } else {
                homeReady = false
                router.popToAuthRoot()
            }
        }
    }

    // MARK: - Auth Flow

    private var authFlow: some View {
        NavigationStack(path: Bindable(router).authPath) {
            authRoot
        }
        .sheet(item: Bindable(router).authSheet, onDismiss: {
            // Fires after the sheet's dismiss animation completes.
            // If the user just verified OTP, transition to home now.
            if authManager.isLoggedIn {
                homeReady = true
            }
        }) { sheet in
            switch sheet {
            case .forgotPassword:
                ForgotPasswordView(authManager: authManager)
                    .presentationDetents([.fraction(0.72), .large])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
                    .presentationBackground(Color.ftdCardBackground)
            case .verifyOTP:
                VerifyOTPView(authManager: authManager)
                    .presentationDetents([.fraction(0.70)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
                    .presentationBackground(Color.ftdCardBackground)
            }
        }
    }

    @ViewBuilder
    private var authRoot: some View {
        if authManager.hasAppToken {
            AuthContainerView()
                .navigationBarBackButtonHidden(true)
        } else {
            SplashView {
                try await authManager.fetchAppToken()
            }
        }
    }
}
