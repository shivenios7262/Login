import SwiftUI

struct TrustBanner: View {
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "checkmark.shield.fill")
                .font(.title2)
                .foregroundStyle(Color.ftdAccentTeal)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text("Secure & Trusted")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.ftdAccentTeal)
                Text("Your data is safe with us, We never share your information")
                    .font(.caption)
                    .foregroundStyle(Color.ftdTextSecondary)
            }

            Spacer()
        }
        .padding()
        .background(Color.ftdInputBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .stroke(Color.ftdBorder, lineWidth: 1)
        )
    }
}
