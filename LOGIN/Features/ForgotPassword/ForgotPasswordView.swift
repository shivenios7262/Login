import SwiftUI

struct ForgotPasswordView: View {
    @State private var viewModel = ForgotPasswordViewModel()
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    var body: some View {
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
    }

    // MARK: - Form

    private var formContent: some View {
        VStack(spacing: 24) {
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

            FTDTextField(
                label: "",
                placeholder: String(localized: "Email Address*"),
                text: emailBinding,
                errorMessage: viewModel.emailError,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )

            FTDPrimaryButton(
                title: String(localized: "Send Reset Link"),
                isLoading: viewModel.isLoading
            ) {
                Task { await viewModel.sendResetLink() }
            }

            whatsNextCard

            Spacer(minLength: 16)

            loginHereFooter
        }
    }

    private var emailBinding: Binding<String> {
        .init(get: { viewModel.email }, set: { viewModel.email = $0 })
    }

    // MARK: - What's Next Card

    private var whatsNextCard: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.14))
                    .frame(width: 36, height: 36)
                Image(systemName: "info.circle.fill")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.blue)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("What's Next?")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.blue)
                Text("We'll send a password reset link to your registered email address.")
                    .font(.caption)
                    .foregroundStyle(Color.ftdTextSecondary)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(Color.blue.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
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

    // MARK: - Success State

    private var successContent: some View {
        VStack(spacing: 24) {
            Spacer(minLength: 24)

            ZStack {
                Circle()
                    .fill(Color.ftdAccentOrange.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image("mail")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.ftdAccentOrange)
            }

            VStack(spacing: 8) {
                Text("Check Your Email")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(Color.ftdTextPrimary)

                Group {
                    Text("We have sent a Password reset link to\n") +
                    Text(viewModel.email)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.ftdAccentOrange)
                }
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
                .multilineTextAlignment(.center)

                Text("Please check your inbox and click on the link to reset your password")
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 4)
            }

            FTDPrimaryButton(title: String(localized: "Open Email"), leadingIcon: "envelope.fill") {
                if let url = URL(string: "message://") {
                    openURL(url)
                }
            }

            Spacer(minLength: 0)
        }
    }
}
