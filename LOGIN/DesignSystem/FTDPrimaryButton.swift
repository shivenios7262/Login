import SwiftUI

struct FTDPrimaryButton: View {
    let title: String
    var leadingIcon: String? = nil
    var trailingIcon: String? = nil
    var isLoading: Bool = false
    var fontSize: CGFloat = 16
    var fontWeight: Font.Weight = .medium
    let action: () -> Void

    private var titleFont: Font {
        .system(size: fontSize, weight: fontWeight)
    }

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        if let icon = leadingIcon {
                            Image(systemName: icon)
                                .font(titleFont)
                        }
                        Text(title)
                            .font(titleFont)
                        if let icon = trailingIcon {
                            Image(systemName: icon)
                                .font(titleFont)
                        }
                    }
                    .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color.ftdAccentOrange)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
        }
        .disabled(isLoading)
    }
}
