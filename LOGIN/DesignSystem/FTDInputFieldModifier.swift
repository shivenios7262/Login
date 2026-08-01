import SwiftUI

/// Shared container style applied to all FTD input field types.
/// Provides consistent padding, border, and error-state colouring.
struct FTDInputContainerModifier: ViewModifier {
    let hasError: Bool

    private var borderColor: Color {
        hasError ? .ftdDestructiveRed : .ftdBorder
    }

    func body(content: Content) -> some View {
        content
            .padding(.horizontal, DesignTokens.Spacing.inputHorizontal)
            .frame(height: DesignTokens.Spacing.inputFieldHeight)
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                    .stroke(borderColor, lineWidth: 1)
            )
    }
}

extension View {
    func ftdInputContainer(hasError: Bool = false) -> some View {
        modifier(FTDInputContainerModifier(hasError: hasError))
    }
}
