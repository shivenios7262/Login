import SwiftUI

struct TrustBanner: View {
    var body: some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
            Image(systemName: "checkmark.shield")
                .font(.system(size: DesignTokens.IconSize.lg))
                .foregroundStyle(Color.blue)

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text("Secure & Trusted")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.blue)
                Text("Your data is safe with us, We never share your information")
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
