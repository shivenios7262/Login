import SwiftUI

struct RootView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AppRouter.self)   private var router

    var body: some View {
        Group {
            if authManager.isLoggedIn {
                FTDHomeView(authManager: authManager)
            } else {
                authFlow
            }
        }
        .onChange(of: authManager.isLoggedIn) { _, isLoggedIn in
            if !isLoggedIn { router.popToAuthRoot() }
        }
    }

    // MARK: - Auth Flow

    private var authFlow: some View {
        NavigationStack(path: Bindable(router).authPath) {
            authRoot
//                .navigationDestination(for: AppRouter.AuthDestination.self) { dest in
//                    switch dest {
//                    case .verifyOTP:
//                        VerifyOTPView(authManager: authManager)
//                    }
//                }
        }
        .sheet(item: Bindable(router).authSheet) { sheet in
            switch sheet {
            case .forgotPassword:
                ForgotPasswordView()
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
