import SwiftUI

struct ForgotPasswordView: View {
    let authManager: AuthManager
    @State private var viewModel: ForgotPasswordViewModel
    @State private var showMailUnavailableAlert = false

    init(authManager: AuthManager) {
        self.authManager = authManager
        _viewModel = State(initialValue: ForgotPasswordViewModel(authManager: authManager))
    }
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.showSuccess {
                    successContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                } else {
                    formContent
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                }
            }
            .animation(.easeInOut(duration: 0.35), value: viewModel.showSuccess)
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.ftdCardBackground)
            .toolbar(.hidden, for: .navigationBar)
            .alert("No Email App Found", isPresented: $showMailUnavailableAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please set up an email app on your device to open your email.")
            }
        }
    }

    private func openMailApp() {
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

    // MARK: - Form

    private var formContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: 8) {
                Text("Forgot password")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.ftdTextPrimary)
                    .frame(maxWidth: .infinity, alignment: .center)
                Text("No worries! Enter your registered email address")
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()

            FTDTextField(
                label: "",
                placeholder: String(localized: "Email Address*"),
                text: emailBinding,
                errorMessage: viewModel.emailError,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )

            Spacer()

            if let apiError = viewModel.apiError {
                Text(apiError)
                    .font(.caption)
                    .foregroundStyle(Color.red)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 4)
            }

            FTDPrimaryButton(
                title: String(localized: "Send Reset Link"),
                isLoading: viewModel.isLoading
            ) {
                Task { await viewModel.sendResetLink() }
            }

            Spacer()

            InfoBanner(
                icon: .asset("iconShield"),
                title: "What's Next?",
                message: "We'll send a password reset link to your registered email address."
            )

            Spacer()

            loginHereFooter
        }
    }

    private var emailBinding: Binding<String> {
        .init(get: { viewModel.email }, set: { viewModel.email = $0 })
    }

    // MARK: - Success State

    private var successContent: some View {
        VStack(spacing: 0) {
            Spacer()

            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 96)
                .padding(.bottom, 24)

            Image("mail")
                .resizable()
                .scaledToFit()
                .frame(width: 145)
                .padding(.bottom, 24)

            Text("Check Your Email")
                .font(.ftdTitleLG)
                .foregroundStyle(Color.ftdTextPrimary)
                .padding(.bottom, 10)

            VStack(spacing: 2) {
                Text("We have sent a Password reset link to")
                    .font(.ftdBodyMD)
                    .foregroundStyle(Color.ftdTextSecondary)
                Text(viewModel.email)
                    .font(.ftdLabelSM)
                    .foregroundStyle(Color.ftdAccentOrange)
            }
            .multilineTextAlignment(.center)
            .padding(.bottom, 12)

            Text("Please check your inbox and click on the link\nto reset your password")
                .font(.ftdBodyMD)
                .foregroundStyle(Color.ftdTextSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Spacer()

            FTDPrimaryButton(title: "Open Email", leadingIcon: "envelope.fill") {
                openMailApp()
            }
            .padding(.bottom, 16)

            Button("Cancel") {
                dismiss()
            }
            .font(.ftdButton)
            .foregroundStyle(Color.ftdTextSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Footer

    private var loginHereFooter: some View {
        HStack(spacing: 4) {
            Text("Remember your password?")
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
            Button("Login Here") {
                dismiss()
            }
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(Color.ftdAccentOrange)
            .buttonStyle(.plain)
        }
    }

}
