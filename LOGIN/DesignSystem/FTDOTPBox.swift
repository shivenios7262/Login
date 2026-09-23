import SwiftUI

/// Read-only OTP digit box shared by VerifyOTPView (with TextField overlay) and AppCodeView.
/// Handles all four visual states: cursor, empty placeholder, masked, and revealed digit.
struct FTDOTPBox: View {
    let digit: String
    var isFocused: Bool = false
    var isMasked: Bool = false
    /// Show the blinking cursor bar — only when the box is focused and empty in an interactive context.
    var showCursor: Bool = false

    var body: some View {
        ZStack {
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

            if showCursor && digit.isEmpty {
                Rectangle()
                    .fill(Color.ftdAccentOrange)
                    .frame(width: 2, height: 24)
            } else if digit.isEmpty {
                Text("✼")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.ftdTextSecondary.opacity(0.4))
            } else if isMasked {
                Text("✼")
                    .font(.system(size: 18))
                    .foregroundStyle(Color.ftdTextPrimary)
            } else {
                Text(digit)
                    .font(.ftdOTPDigit)
                    .foregroundStyle(Color.ftdAccentOrange)
            }
        }
    }
}
