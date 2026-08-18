import SwiftUI

struct CheckEmailView: View {
    let email: String
    // let authManager: AuthManager  // kept for when Reset Password API is available
    let dismissSheet: DismissAction

    @Environment(\.openURL) private var openURL
    @State private var showMailUnavailableAlert = false
    // @State private var showResetPassword = false  // reset password flow pending API

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                FTDAuthLogo()

                ZStack {
                    Circle()
                        .fill(Color.ftdAccentOrange.opacity(0.12))
                        .frame(width: 96, height: 96)
                    Image(systemName: "envelope.badge.checkmark.fill")
                        .font(.system(size: 44))
                        .foregroundStyle(Color.ftdAccentOrange)
                }
                .padding(.top, 8)

                VStack(spacing: 10) {
                    Text("Check Your Email")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.ftdTextPrimary)
                    Text("We have sent password recovery instructions to **\(email)**.")
                        .font(.subheadline)
                        .foregroundStyle(Color.ftdTextSecondary)
                        .multilineTextAlignment(.center)
                }

                FTDPrimaryButton(title: String(localized: "Open Email App"), leadingIcon: "envelope.fill") {
                    openMailApp()
                }

                Button(String(localized: "Cancel")) {
                    dismissSheet()
                }
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)

                // Reset Password with OTP — commented until backend API is available
                // Button(String(localized: "Reset Password with OTP")) {
                //     showResetPassword = true
                // }
                // .font(.subheadline)
                // .foregroundStyle(Color.ftdAccentOrange)

                Text("Did not receive the email? Check your spam folder or try another address.")
                    .font(.caption)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 32)
        }
        .background(Color.ftdCardBackground.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .alert("No Email App Found", isPresented: $showMailUnavailableAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Please set up an email app on your device to open your email.")
        }
        // .navigationDestination(isPresented: $showResetPassword) {
        //     ResetPasswordView(email: email, authManager: authManager, dismissSheet: dismissSheet)
        // }
    }

    private func openMailApp() {
        // Try Apple Mail first, then a generic mailto scheme
        let mailURL = URL(string: "message://")!
        let mailtoURL = URL(string: "mailto:")!
        if UIApplication.shared.canOpenURL(mailURL) {
            openURL(mailURL)
        } else if UIApplication.shared.canOpenURL(mailtoURL) {
            openURL(mailtoURL)
        } else {
            showMailUnavailableAlert = true
        }
    }
}
