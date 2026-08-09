import SwiftUI

struct CheckEmailView: View {
    let email: String
    let authManager: AuthManager
    let dismissSheet: DismissAction

    @State private var showResetPassword = false

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

                FTDPrimaryButton(title: String(localized: "Return to Sign In")) {
                    dismissSheet()
                }

                Button(String(localized: "Reset Password with OTP")) {
                    showResetPassword = true
                }
                .font(.subheadline)
                .foregroundStyle(Color.ftdAccentOrange)

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
        .navigationDestination(isPresented: $showResetPassword) {
            ResetPasswordView(email: email, authManager: authManager, dismissSheet: dismissSheet)
        }
    }
}
