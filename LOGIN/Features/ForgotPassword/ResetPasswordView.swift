import SwiftUI

struct ResetPasswordView: View {
    let dismissSheet: DismissAction
    @State private var viewModel: ResetPasswordViewModel

    private enum Layout {
        static let errorCornerRadius: CGFloat    = DesignTokens.Radius.field
        static let errorVerticalPadding: CGFloat = DesignTokens.Spacing.inputVertical
        static let errorHorizontalPadding: CGFloat = DesignTokens.Spacing.inputHorizontal
    }

    init(email: String, authManager: AuthManager, dismissSheet: DismissAction) {
        self.dismissSheet = dismissSheet
        _viewModel = State(initialValue: ResetPasswordViewModel(authManager: authManager, email: email))
    }

    var body: some View {
        @Bindable var vm = viewModel

        ScrollView {
            VStack(spacing: 28) {
                FTDAuthLogo()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Reset Password")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.ftdTextPrimary)
                    Text("Enter your agent number and create a strong new password.")
                        .font(.subheadline)
                        .foregroundStyle(Color.ftdTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if vm.isSuccess {
                    successBanner
                } else {
                    FTDTextField(
                        label: "",
                        placeholder: String(localized: "Agent Number"),
                        text: $vm.agentNo,
                        errorMessage: vm.agentNoError,
                        keyboardType: .default,
                        autocapitalization: .characters
                    )

                    FTDSecureField(
                        label: String(localized: "New Password"),
                        placeholder: String(localized: "New Password"),
                        text: $vm.newPassword,
                        isVisible: $vm.showNewPassword,
                        errorMessage: vm.newPasswordError
                    )

                    FTDSecureField(
                        label: String(localized: "Confirm Password"),
                        placeholder: String(localized: "Confirm Password"),
                        text: $vm.confirmPassword,
                        isVisible: $vm.showConfirmPassword,
                        errorMessage: vm.confirmPasswordError
                    )

                    apiErrorBanner

                    FTDPrimaryButton(
                        title: String(localized: "Reset Password"),
                        isLoading: vm.isLoading
                    ) {
                        Task { await vm.resetPassword() }
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 32)
            .padding(.bottom, 32)
        }
        .background(Color.ftdCardBackground.ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    private var apiErrorBanner: some View {
        if let error = viewModel.apiError {
            Text(error)
                .font(.subheadline)
                .foregroundStyle(Color.ftdDestructiveRed)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Layout.errorVerticalPadding)
                .padding(.horizontal, Layout.errorHorizontalPadding)
                .background(Color.ftdDestructiveRed.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: Layout.errorCornerRadius))
        }
    }

    private var successBanner: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.green)
            }
            Text("Password reset successfully!")
                .font(.headline)
                .foregroundStyle(Color.ftdTextPrimary)
            Text("You can now sign in with your new password.")
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
                .multilineTextAlignment(.center)
            FTDPrimaryButton(title: String(localized: "Return to Sign In")) {
                dismissSheet()
            }
        }
        .padding(.top, 8)
    }
}
