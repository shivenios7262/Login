import SwiftUI

//#Preview {
//    let keychain = KeychainService()
//    let apiClient = APIClient(
//        httpClient: URLSessionHTTPClient(),
//        baseURL: URL(string: "http://localhost")!,
//        keychain: keychain,
//        appCredentials: AppCredentials(appType: 1, appUser: "", appPassword: "", appVersion: "1.0", persistAppToken: false)
//    )
//    let authManager = AuthManager(apiClient: apiClient, keychain: keychain)
//    NavigationStack {
//        VerifyOTPView(authManager: authManager)
//    }
//    .environment(authManager)
//}

struct VerifyOTPView: View {
    @State private var viewModel: VerifyOTPViewModel

    init(authManager: AuthManager) {
        _viewModel = State(initialValue: VerifyOTPViewModel(authManager: authManager))
    }

    var body: some View {
        @Bindable var vm = viewModel

        ScrollView {
            VStack(spacing: 24) {
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
                        .foregroundStyle(Color("DestructiveRed"))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color("DestructiveRed").opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                if let msg = vm.resendMessage {
                    Text(msg)
                        .font(.subheadline)
                        .foregroundStyle(Color.green)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color.green.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                FTDPrimaryButton(
                    title: String(localized: "Verify OTP"),
                    isLoading: vm.isLoading
                ) {
                    Task { await vm.verify() }
                }

                resendSection
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 36)
        }
        .background(Color("CardBackground").ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .onDisappear { viewModel.onDisappear() }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.shield")
                .font(.system(size: 48))
                .foregroundStyle(Color("AccentOrange"))
            Text("Verify OTP")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color("TextPrimary"))
            if viewModel.otpEmail.isEmpty {
                Text("Enter the OTP sent to your registered email address")
                    .font(.subheadline)
                    .foregroundStyle(Color("TextSecondary"))
                    .multilineTextAlignment(.center)
            } else {
                Group {
                    Text("OTP sent to ") +
                    Text(viewModel.otpEmail)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color("TextPrimary"))
                }
                .font(.subheadline)
                .foregroundStyle(Color("TextSecondary"))
                .multilineTextAlignment(.center)
            }
        }
    }

    private var resendSection: some View {
        VStack(spacing: 8) {
            if viewModel.resendCooldown > 0 {
                Text("Resend OTP in \(viewModel.timerDisplay)")
                    .font(.subheadline)
                    .foregroundStyle(Color("TextSecondary"))
            }

            Button {
                Task { await viewModel.resend() }
            } label: {
                if viewModel.isResending {
                    ProgressView()
                        .tint(Color("AccentOrange"))
                } else {
                    Text("Resend OTP")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(
                            viewModel.canResend ? Color("AccentOrange") : Color("TextSecondary")
                        )
                }
            }
            .disabled(!viewModel.canResend)
        }
    }
}
