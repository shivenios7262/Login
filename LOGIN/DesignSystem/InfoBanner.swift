import SwiftUI

enum InfoBannerIcon {
    case system(String)
    case asset(String)
}

struct InfoBanner: View {
    let icon: InfoBannerIcon
    var showIconBackground: Bool = false
    var iconTint: Color = .ftdMessageTextInfo
    var iconBackgroundcolor: Color = .ftdMessageIconBGInfo
    
    var backgroundColor: Color = .ftdMessageBGInfo
    let title: LocalizedStringKey
    let message: LocalizedStringKey

    var body: some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.md) {
            iconView
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(title)
                    .font(.ftdLabelMD)
                    .foregroundStyle(iconTint)
                Text(message)
                    .font(.ftdPlaceholder)
                    .foregroundStyle(Color.ftdTextSecondary)
            }
            Spacer()
        }
        .padding(DesignTokens.Spacing.md)
        .background(backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
    }

    @ViewBuilder
    private var rawIcon: some View {
        switch icon {
        case .system(let name):
            Image(systemName: name)
                .font(.system(size: DesignTokens.IconSize.lg))
                .foregroundStyle(iconTint)
        case .asset(let name):
            Image(name)
                .resizable()
                .scaledToFit()
                .foregroundStyle(iconTint)
                .frame(width: DesignTokens.IconSize.lg, height: DesignTokens.IconSize.lg)
        }
    }

    @ViewBuilder
    private var iconView: some View {
        if showIconBackground {
            rawIcon
                .padding(DesignTokens.Spacing.sm)
                .background(iconBackgroundcolor)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
        } else {
            rawIcon
        }
    }
}
