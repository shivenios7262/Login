import SwiftUI

struct FTDPrimaryButton: View {
    let title: String
    var leadingIcon: String? = nil
    var trailingIcon: String? = nil
    var isLoading: Bool = false
    var font: Font = .ftdButton
    let action: () -> Void

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
                                .font(font)
                        }
                        Text(title)
                            .font(font)
                        if let icon = trailingIcon {
                            Image(systemName: icon)
                                .font(font)
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
