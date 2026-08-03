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
            .background(Color.ftdCardBackground, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
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

/// Builds a `Text` where every `*` is rendered in `ftdDestructiveRed`
/// and the rest in `ftdTextSecondary`.
func ftdRequiredLabel(_ text: String) -> Text {
    let parts = text.components(separatedBy: "*")
    guard parts.count > 1 else {
        return Text(text).foregroundStyle(Color.ftdTextSecondary)
    }
    var result = Text(parts[0]).foregroundStyle(Color.ftdTextSecondary)
    for part in parts.dropFirst() {
        result = result + Text("*").foregroundStyle(Color.ftdDestructiveRed)
        if !part.isEmpty {
            result = result + Text(part).foregroundStyle(Color.ftdTextSecondary)
        }
    }
    return result
}
