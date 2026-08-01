import SwiftUI

struct FTDPrimaryButton: View {
    let title: String
    var trailingIcon: String? = nil
    var isLoading: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text(title)
                            .fontWeight(.semibold)
                        if let icon = trailingIcon {
                            Image(systemName: icon)
                                .fontWeight(.medium)
                        }
                    }
                    .foregroundStyle(.white)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 48)
            .background(Color.ftdAccentOrange)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
        }
        .disabled(isLoading)
    }
}
