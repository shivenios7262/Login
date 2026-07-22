import SwiftUI

struct SignInView: View {
    private let authManager: AuthManager
    @State private var viewModel: SignInViewModel

    init(authManager: AuthManager) {
        self.authManager = authManager
        _viewModel = State(initialValue: SignInViewModel(authManager: authManager))
    }

    var body: some View {
        @Bindable var vm = viewModel

        VStack(spacing: 20) {
            FTDDropdownField(
                label: String(localized: "Select User Type"),
                placeholder: String(localized: "Select User Type"),
                selection: $vm.selectedUserType,
                options: UserType.allCases,
                optionLabel: { $0.displayName }
            )

            FTDTextField(
                label: String(localized: "Agent Email ID"),
                placeholder: String(localized: "eg: abhishek.ftd@xyz.com"),
                text: $vm.email,
                errorMessage: vm.emailError,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )

            FTDSecureField(
                label: String(localized: "Password"),
                placeholder: String(localized: "Enter password"),
                text: $vm.password,
                isVisible: $vm.showPassword,
                errorMessage: vm.passwordError
            )

            HStack {
                Spacer()
                Button(String(localized: "Forgot Password?")) {
                    vm.showForgotPassword = true
                }
                .font(.subheadline)
                .foregroundStyle(Color("AccentOrange"))
            }

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

            FTDPrimaryButton(
                title: String(localized: "Login"),
                isLoading: vm.isLoading
            ) {
                Task { await vm.login() }
            }

            TrustBanner()
                .padding(.top, 4)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
        .sheet(isPresented: $vm.showForgotPassword) {
            NavigationStack {
                ForgotPasswordView()
            }
        }
        .navigationDestination(isPresented: $vm.showOTP) {
            VerifyOTPView(authManager: authManager)
        }
    }
}
