import SwiftUI

struct ResetPasswordView: View {
    let dismissSheet: DismissAction
    @State private var viewModel = ResetPasswordViewModel()

    var body: some View {
        @Bindable var vm = viewModel

        ScrollView {
            VStack(spacing: 28) {
                FTDAuthLogo()

                VStack(alignment: .leading, spacing: 8) {
                    Text("Reset Password")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color("TextPrimary"))
                    Text("Create a strong new password for your account.")
                        .font(.subheadline)
                        .foregroundStyle(Color("TextSecondary"))
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if vm.isSuccess {
                    successBanner
                } else {
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
        .background(Color("CardBackground").ignoresSafeArea())
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
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
                .foregroundStyle(Color("TextPrimary"))
            Text("You can now sign in with your new password.")
                .font(.subheadline)
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
            FTDPrimaryButton(title: String(localized: "Return to Sign In")) {
                dismissSheet()
            }
        }
        .padding(.top, 8)
    }
}
