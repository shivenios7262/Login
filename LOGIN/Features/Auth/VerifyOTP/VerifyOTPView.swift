import SwiftUI

struct VerifyOTPView: View {
    @State private var viewModel: VerifyOTPViewModel

    init(authManager: AuthManager) {
        _viewModel = State(initialValue: VerifyOTPViewModel(authManager: authManager))
    }

    var body: some View {
        @Bindable var vm = viewModel

        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xxl) {
                header
                    .padding(.top, 32)

                FTDTextField(
                    label: String(localized: "OTP"),
                    placeholder: String(localized: "Enter OTP"),
                    text: $vm.otp,
                    keyboardType: .numberPad,
                    autocapitalization: .never
                )

                if let error = vm.apiError {
                    Text(error)
                        .font(.subheadline)
                        .foregroundStyle(Color.ftdDestructiveRed)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignTokens.Spacing.inputVertical)
                        .padding(.horizontal, DesignTokens.Spacing.inputHorizontal)
                        .background(Color.ftdDestructiveRed.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                }

                if let msg = vm.resendMessage {
                    Text(msg)
                        .font(.subheadline)
                        .foregroundStyle(Color.green)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignTokens.Spacing.inputVertical)
                        .padding(.horizontal, DesignTokens.Spacing.inputHorizontal)
                        .background(Color.green.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                }

                FTDPrimaryButton(
                    title: String(localized: "Verify OTP"),
                    isLoading: vm.isLoading
                ) {
                    Task { await vm.verify() }
                }

                resendSection
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
            .padding(.bottom, DesignTokens.Spacing.screenBottom)
        }
        .background(Color.ftdCardBackground.ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onDisappear { viewModel.onDisappear() }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "lock.shield")
                .font(.ftdHeroIcon)
                .foregroundStyle(Color.ftdAccentOrange)
            Text("Verify OTP")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.ftdTextPrimary)
            if viewModel.otpEmail.isEmpty {
                Text("Enter the OTP sent to your registered email address")
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
            } else {
                Group {
                    Text("OTP sent to ") +
                    Text(viewModel.otpEmail)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.ftdTextPrimary)
                }
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
                .multilineTextAlignment(.center)
            }
        }
    }

    // MARK: - Resend Section

    private var resendSection: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            if viewModel.resendCooldown > 0 {
                Text("Resend OTP in \(viewModel.timerDisplay)")
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
            }

            Button {
                Task { await viewModel.resend() }
            } label: {
                if viewModel.isResending {
                    ProgressView()
                        .tint(Color.ftdAccentOrange)
                } else {
                    Text("Resend OTP")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            viewModel.canResend ? Color.ftdAccentOrange : Color.ftdTextSecondary
                        )
                }
            }
            .disabled(!viewModel.canResend)
        }
    }
}
