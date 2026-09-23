import SwiftUI

struct AppCodeView: View {
    var viewModel: AppCodeViewModel
    @Environment(\.dismiss) private var dismiss

    private func secondsRemaining(at date: Date) -> Int {
        guard let expiry = viewModel.otpExpiryDate else { return Int.max }
        return max(0, Int(expiry.timeIntervalSince(date)))
    }

    private var digits: [String] {
        Array(viewModel.otpCode ?? "").map { String($0) }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: DesignTokens.Spacing.xxl) {
                header
                    .padding(.top, 32)

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

                codeSection

                if viewModel.otpExpiryDate != nil && !viewModel.isLoading && secondsRemaining(at: Date()) > 0 {
                    TimelineView(.periodic(from: .now, by: 1)) { context in
                        countdownLabel(at: context.date)
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
            .padding(.bottom, DesignTokens.Spacing.screenBottom)
        }
        .background(Color.ftdCardBackground.ignoresSafeArea())
        .presentationDetents([.height(380)])
        .presentationDragIndicator(.visible)
        .task {
            await viewModel.fetchCode()
            await monitorExpiry()
        }
        .onDisappear {
            viewModel.reset()
        }
    }

    // MARK: - Header

    private var header: some View {
        VStack(spacing: DesignTokens.Spacing.xxl) {
            Text(String(localized: "App Code"))
                .font(.ftdTitleLG)
                .foregroundStyle(Color.ftdTextPrimary)

            Text(String(localized: "Enter this code to login to FTD web"))
                .font(.ftdBodyMD)
                .foregroundStyle(Color.ftdTextTertiary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Code Boxes

    private var codeSection: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            if viewModel.isLoading {
                ProgressView()
                    .tint(Color.ftdAccentOrange)
                    .frame(height: 64)
            } else {
                HStack(spacing: DesignTokens.Spacing.md) {
                    ForEach(0..<digits.count, id: \.self) { i in
                        FTDOTPBox(digit: digits[i], isMasked: false)
                    }
                }
                .padding(.vertical, DesignTokens.Spacing.sm)
            }

            Rectangle()
                .fill(Color.ftdAccentOrange)
                .frame(height: 2)
        }
    }

    // MARK: - Countdown

    private func countdownLabel(at date: Date) -> some View {
        let seconds = secondsRemaining(at: date)
        let display = seconds == Int.max ? 0 : seconds
        return (
            Text(String(localized: "Changes in "))
                .font(.ftdBodyMD)
                .foregroundStyle(Color.ftdTextTertiary)
            + Text(String(format: "%02d:%02d", display / 60, display % 60))
                .font(.ftdLabelMD)
                .foregroundStyle(Color.ftdAccentOrange)
        )
        .multilineTextAlignment(.center)
    }

    // MARK: - Expiry Monitor

    // Dismisses the sheet when the code expires.
    @MainActor
    private func monitorExpiry() async {
        guard viewModel.otpExpiryDate != nil else { return }
        // Only dismiss if the OTP was still valid when we started watching.
        // If it's already expired on load, show it without auto-dismissing.
        guard secondsRemaining(at: Date()) > 0 else { return }
        while !Task.isCancelled {
            try? await Task.sleep(for: .seconds(1))
            guard !Task.isCancelled else { return }
            if secondsRemaining(at: Date()) == 0 {
                dismiss()
                return
            }
        }
    }
}
