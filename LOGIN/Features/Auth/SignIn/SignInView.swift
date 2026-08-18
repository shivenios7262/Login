import SwiftUI

struct SignInView: View {
    private let authManager: AuthManager
    @State private var viewModel: SignInViewModel

    private enum Layout {
        static let fieldSpacing: CGFloat       = DesignTokens.Spacing.fieldSpacing
        static let errorCornerRadius: CGFloat  = DesignTokens.Radius.field
        static let errorVerticalPadding: CGFloat   = DesignTokens.Spacing.inputVertical
        static let errorHorizontalPadding: CGFloat = DesignTokens.Spacing.inputHorizontal
    }

    init(authManager: AuthManager, router: AppRouter) {
        self.authManager = authManager
        _viewModel = State(initialValue: SignInViewModel(authManager: authManager, router: router))
    }

    var body: some View {
        VStack(spacing: 0) {
            userTypeSection
                .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
                .padding(.top, DesignTokens.Spacing.xl)

            VStack(spacing: Layout.fieldSpacing) {
                credentialsSection
                forgotPasswordRow
                apiErrorBanner
                loginButton
                TrustBanner()
                    .padding(.top, DesignTokens.Spacing.xs)
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
            .padding(.top, Layout.fieldSpacing)
            .padding(.bottom, DesignTokens.Spacing.screenBottom)
            .background(Color.clear/*ftdCardBackground*/)
        }
    }

    // MARK: - User Type

    private var userTypeSection: some View {
        @Bindable var vm = viewModel
        return FTDDropdownField(
            label: String(localized: "Choose User Type"),
            placeholder: String(localized: "Choose User Type"),
            selection: $vm.selectedUserType,
            options: UserType.allCases,
            optionLabel: { $0.displayName },
            optionIcon: { $0.systemImage }
        )
    }

    // MARK: - Credentials

    private var credentialsSection: some View {
        @Bindable var vm = viewModel
        return VStack(spacing: Layout.fieldSpacing) {
            FTDTextField(
                label: "",
                placeholder: String(localized: "Agent Email ID"),
                text: $vm.email,
                errorMessage: vm.emailError,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            FTDSecureField(
                label: "",
                placeholder: String(localized: "Password"),
                text: $vm.password,
                isVisible: $vm.showPassword,
                errorMessage: vm.passwordError
            )
        }
        //.background(Color.red)
    }

    // MARK: - Forgot Password

    private var forgotPasswordRow: some View {
        HStack {
            Spacer()
            Button(String(localized: "Forgot Password?")) {
                viewModel.tapForgotPassword()
            }
            .font(.ftdLabelMD)
            .foregroundStyle(Color.ftdAccentOrange)
        }
    }

    // MARK: - API Error Banner

    @ViewBuilder
    private var apiErrorBanner: some View {
        if let error = viewModel.apiError {
            Text(error)
                .font(.ftdBodySM)
                .foregroundStyle(Color.ftdDestructiveRed)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Layout.errorVerticalPadding)
                .padding(.horizontal, Layout.errorHorizontalPadding)
                .background(Color.ftdDestructiveRed.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: Layout.errorCornerRadius))
        }
    }

    // MARK: - Login Button

    private var loginButton: some View {
        FTDPrimaryButton(
            title: String(localized: "Login"),
            isLoading: viewModel.isLoading
        ) {
            Task { await viewModel.login() }
        }
    }
}

// MARK: - Preview
/*
#Preview("Sign In") {
    struct PreviewKeychain: KeychainServiceProtocol {
        func save(key: KeychainKey, value: String) {}
        @discardableResult func delete(key: KeychainKey) -> Bool { false }
        func read(key: KeychainKey) -> String? { nil }
    }
    struct PreviewHTTPClient: HTTPClientProtocol {
        func send<T: Decodable>(_ urlRequest: URLRequest) async throws -> T {
            throw URLError(.notConnectedToInternet)
        }
    }
    let keychain = PreviewKeychain()
    let apiClient = APIClient(
        httpClient: PreviewHTTPClient(),
        baseURL: URL(string: "https://preview.example.com")!,
        keychain: keychain,
        appCredentials: AppCredentials(appType: 1, appUser: "", appPassword: "", appVersion: "1.0", persistAppToken: false)
    )
    let authManager = AuthManager(apiClient: apiClient, keychain: keychain)
    let router = AppRouter()
    return ScrollView {
        SignInView(authManager: authManager, router: router)
            .padding(.top, DesignTokens.Spacing.xl)
    }
    .background(Color.ftdCardBackground)
}

*/
