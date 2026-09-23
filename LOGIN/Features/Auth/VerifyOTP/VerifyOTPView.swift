import SwiftUI

struct VerifyOTPView: View {
    @State private var viewModel: VerifyOTPViewModel
    @State private var digits: [String] = ["", "", "", ""]
    @State private var maskedDigits: Set<Int> = []
    @FocusState private var focusedField: Int?
    private let maskingEnabled = false   // TODO: set to true before shipping

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
                        .font(.ftdBodyMD)
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
                        .font(.ftdBodyMD)
                        .foregroundStyle(Color.ftdMessageTextSuccess)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignTokens.Spacing.inputVertical)
                        .padding(.horizontal, DesignTokens.Spacing.inputHorizontal)
                        .background(Color.ftdMessageBGSuccess)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                }

                resendSection

                FTDPrimaryButton(
                    title: String(localized: "Verify & Continue"),
                    isLoading: viewModel.isLoading
                ) {
                    Task { await viewModel.verify() }
                }

                InfoBanner(
                    icon: .asset("iconShield"),
                    showIconBackground: true,
                    iconTint: .ftdAccentTeal,
                    title: "Additional verification required",
                    message: "Your code is valid for 10 minutes, To finish signing in, enter the code."
                )
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
        VStack(spacing: DesignTokens.Spacing.xxl) {
            Text(String(localized: "OTP Verification"))
                .font(.ftdTitleLG)
                .foregroundStyle(Color.ftdTextPrimary)

            VStack(spacing: DesignTokens.Spacing.xxs) {
                Text(String(localized: "Enter the 4 digit code sent to"))
                    .font(.ftdBodyMD)
                    .foregroundStyle(Color.ftdTextTertiary)

                if !viewModel.otpEmail.isEmpty {
                    Text(viewModel.otpEmail)
                        .font(.ftdLabelMD)
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
            FTDOTPBox(
                digit: digit,
                isFocused: isFocused,
                isMasked: maskedDigits.contains(index),
                showCursor: digit.isEmpty && isFocused
            )

            TextField("", text: $digits[index])
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .focused($focusedField, equals: index)
                .frame(width: 64, height: 64)
                .multilineTextAlignment(.center)
                .foregroundColor(.clear)
                .tint(.clear)
                .onChange(of: digits[index]) { _, newVal in
                    let filtered = newVal.filter { $0.isNumber }
                    // When the box was already filled and the user types a new digit,
                    // filtered has 2 chars — take the last one (the newly typed digit).
                    let clean = filtered.count > 1
                        ? String(filtered.suffix(1))
                        : String(filtered.prefix(1))
                    if newVal != clean {
                        digits[index] = clean
                        return
                    }
                    if !clean.isEmpty {
                        maskedDigits.remove(index)
                        if maskingEnabled {
                            Task {
                                try? await Task.sleep(for: .seconds(0.6))
                                maskedDigits.insert(index)
                            }
                        }
                        if index < 3 { focusedField = index + 1 }
                    } else {
                        maskedDigits.remove(index)
                    }
                    viewModel.otp = digits.joined()
                }
        }
        .onTapGesture {
            // Tapping a filled box clears it so the user can re-enter the digit.
            if !digits[index].isEmpty {
                digits[index] = ""
                maskedDigits.remove(index)
                viewModel.otp = digits.joined()
            }
            focusedField = index
        }
    }

    // MARK: - Resend Section

    private var resendSection: some View {
        VStack(spacing: DesignTokens.Spacing.xs) {
            Text(String(localized: "Didn't received the code?"))
                .font(.ftdBodyMD)
                .foregroundStyle(Color.ftdTextTertiary)

            if viewModel.resendCooldown > 0 {
                (
                    Text(String(localized: "Resend OTP in "))
                        .foregroundStyle(Color.ftdAccentTeal) +
                    Text(viewModel.timerDisplay)
                        .foregroundStyle(Color.ftdAccentOrange)
                )
                .font(.ftdLabelMD)
            } else {
                Button {
                    Task { await viewModel.resend() }
                } label: {
                    if viewModel.isResending {
                        ProgressView()
                            .tint(Color.ftdAccentOrange)
                    } else {
                        Text(String(localized: "Resend OTP"))
                            .font(.ftdLabelMD)
                            .foregroundStyle(Color.ftdAccentOrange)
                    }
                }
                .disabled(!viewModel.canResend)
            }
        }
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
