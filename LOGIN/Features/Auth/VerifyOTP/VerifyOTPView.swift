import SwiftUI

struct VerifyOTPView: View {
    @State private var viewModel: VerifyOTPViewModel
    @State private var digits: [String] = ["", "", "", ""]
    @State private var maskedDigits: Set<Int> = []
    @FocusState private var focusedField: Int?

    init(authManager: AuthManager) {
        _viewModel = State(initialValue: VerifyOTPViewModel(authManager: authManager))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xxl) {
                header
                    .padding(.top, 32)

                otpBoxes

                if let error = viewModel.apiError {
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

                if let msg = viewModel.resendMessage {
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

                resendSection

                FTDPrimaryButton(
                    title: String(localized: "Verify & Continue"),
                    isLoading: viewModel.isLoading
                ) {
                    Task { await viewModel.verify() }
                }

                infoBanner
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
            Text(String(localized: "OTP Verification"))
                .font(.title2)
                .fontWeight(.bold)
                .foregroundStyle(Color.ftdTextPrimary)

            VStack(spacing: DesignTokens.Spacing.xxs) {
                Text(String(localized: "Enter the 4 digit code sent to"))
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)

                if !viewModel.otpEmail.isEmpty {
                    Text(viewModel.otpEmail)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.ftdAccentOrange)
                }
            }
            .multilineTextAlignment(.center)
        }
    }

    // MARK: - OTP Boxes

    private var otpBoxes: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            ForEach(0..<4, id: \.self) { i in
                otpBox(index: i)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.sm)
    }

    private func otpBox(index: Int) -> some View {
        let isFocused = focusedField == index
        let digit = digits[index]

        return ZStack {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                .stroke(
                    isFocused ? Color.ftdAccentOrange : Color.ftdBorder,
                    lineWidth: 1.5
                )
                .background(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .fill(Color.ftdCardBackground)
                )
                .frame(width: 64, height: 64)

            TextField("", text: $digits[index])
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focusedField, equals: index)
                .frame(width: 64, height: 64)
                .multilineTextAlignment(.center)
                .foregroundColor(.clear)
                .tint(.clear)
                .onChange(of: digits[index]) { _, newVal in
                    let clean = String(newVal.filter { $0.isNumber }.prefix(1))
                    if newVal != clean {
                        digits[index] = clean
                        return
                    }
                    if !clean.isEmpty {
                        // Briefly reveal the digit, then mask after 0.6s
                        maskedDigits.remove(index)
                        Task {
                            try? await Task.sleep(for: .seconds(0.6))
                            maskedDigits.insert(index)
                        }
                        if index < 3 { focusedField = index + 1 }
                    } else {
                        maskedDigits.remove(index)
                    }
                    viewModel.otp = digits.joined()
                }

            if digit.isEmpty && isFocused {
                Rectangle()
                    .fill(Color.ftdAccentOrange)
                    .frame(width: 2, height: 24)
            } else if digit.isEmpty {
                Text("*")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.ftdTextSecondary.opacity(0.4))
            } else if maskedDigits.contains(index) {
                Text("*")
                    .font(.title2)
                    .fontWeight(.medium)
                    .foregroundStyle(Color.ftdTextPrimary)
            } else {
                Text(digit)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.ftdAccentOrange)
            }
        }
        .onTapGesture {
            focusedField = index
        }
    }

    // MARK: - Resend Section

    private var resendSection: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            Text(String(localized: "Didn't received the code?"))
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)

            if viewModel.resendCooldown > 0 {
                (
                    Text(String(localized: "Resend OTP in "))
                        .foregroundStyle(Color.ftdAccentTeal) +
                    Text(viewModel.timerDisplay)
                        .foregroundStyle(Color.ftdAccentOrange)
                )
                .font(.subheadline)
                .fontWeight(.semibold)
            } else {
                Button {
                    Task { await viewModel.resend() }
                } label: {
                    if viewModel.isResending {
                        ProgressView()
                            .tint(Color.ftdAccentOrange)
                    } else {
                        Text(String(localized: "Resend OTP"))
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.ftdAccentOrange)
                    }
                }
                .disabled(!viewModel.canResend)
            }
        }
    }

    // MARK: - Info Banner

    private var infoBanner: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: DesignTokens.IconSize.lg))
                .foregroundStyle(Color.blue)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(String(localized: "Additional verification required"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.blue)

                Text(String(localized: "Your code is valid for 10 minutes, To finish signing in, enter the code."))
                    .font(.caption)
                    .foregroundStyle(Color.ftdTextSecondary)
            }

            Spacer()
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.blue.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
    }
}

//// MARK: - Preview
//
//#Preview {
//    let httpClient = URLSessionHTTPClient()
//    let keychain = KeychainService()
//    let apiClient = APIClient(
//        httpClient: httpClient,
//        baseURL: URL(string: "https://example.com")!,
//        keychain: keychain,
//        appCredentials: AppCredentials(
//            appType: 1,
//            appUser: "preview",
//            appPassword: "preview",
//            appVersion: "1.0",
//            persistAppToken: false
//        )
//    )
//    let authManager = AuthManager(apiClient: apiClient, keychain: keychain)
//    return NavigationStack {
//        VerifyOTPView(authManager: authManager)
//    }
//}
