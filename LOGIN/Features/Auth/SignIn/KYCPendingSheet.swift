import SwiftUI

struct KYCPendingSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

    private let adminEmail = "admin@ftd.travel"

    var body: some View {
        VStack(spacing: 0) {
            iconSection
                .padding(.top, DesignTokens.Spacing.xxxl)
                .padding(.bottom, DesignTokens.Spacing.lg)

            dashedDivider
                .padding(.bottom, DesignTokens.Spacing.lg)

            titleSection
                .padding(.bottom, DesignTokens.Spacing.lg)

            dashedDivider
                .padding(.bottom, DesignTokens.Spacing.lg)

            kycStepsSection
                .padding(.bottom, DesignTokens.Spacing.lg)

            dashedDivider
                .padding(.bottom, DesignTokens.Spacing.lg)

            Spacer()

            contactButton
                .padding(.bottom, DesignTokens.Spacing.screenBottom)
        }
        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        .presentationDetents([.height(520)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(DesignTokens.Radius.cardLg)
    }

    // MARK: - Sections

    private var iconSection: some View {
        Image(systemName: "exclamationmark.triangle")
            .font(.system(size: 56, weight: .medium))
            .foregroundStyle(Color.ftdAccentOrange)
    }

    private var titleSection: some View {
        Text("Your account is not\nactivated yet.")
            .font(.ftdMenuName)
            .foregroundStyle(Color.ftdTextPrimary)
            .multilineTextAlignment(.center)
    }

    private var kycStepsSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Text("Complete your KYC by sending")
                .font(.ftdBodyMD)
                .foregroundStyle(Color.ftdTextSecondary)

            HStack(spacing: DesignTokens.Spacing.md) {
                documentChip(icon: "creditcard", label: "1. PAN Card")
                documentChip(icon: "house", label: "2. Address Proof")
            }

            emailLine
        }
    }

    private var emailLine: some View {
        HStack(spacing: 4) {
            Text("to us on email -")
                .font(.ftdBodyMD)
                .foregroundStyle(Color.ftdTextSecondary)
            Button(adminEmail) {
                openURL(URL(string: "mailto:\(adminEmail)")!)
            }
            .font(.ftdBodyMD)
            .foregroundStyle(Color.ftdAccentOrange)
        }
    }

    private var contactButton: some View {
        FTDPrimaryButton(title: String(localized: "Contact Admin")) {
            openURL(URL(string: "mailto:\(adminEmail)")!)
        }
    }

    // MARK: - Helpers

    private var dashedDivider: some View {
        Rectangle()
            .fill(Color.clear)
            .frame(height: 1)
            .overlay(
                Rectangle()
                    .stroke(style: StrokeStyle(lineWidth: 1, dash: [5, 4]))
                    .foregroundStyle(Color.ftdDivider)
            )
    }

    @ViewBuilder
    private func documentChip(icon: String, label: String) -> some View {
        HStack(spacing: DesignTokens.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: DesignTokens.IconSize.sm, weight: .medium))
                .foregroundStyle(Color.ftdAccentOrange)
            Text(label)
                .font(.ftdLabelXS)
                .foregroundStyle(Color.ftdTextPrimary)
        }
        .padding(.vertical, DesignTokens.Spacing.sm)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .overlay(
            Capsule()
                .stroke(Color.ftdAccentOrange, lineWidth: 1)
        )
    }
}
