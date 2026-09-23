import SwiftUI

struct FTDTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var errorMessage: String?
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences
    var placeholderColor: Color = Color(uiColor: .placeholderText)
    var placeholderFont: Font = Font.ftdBodySM

    private func buildPrompt() -> Text {
        let parts = placeholder.components(separatedBy: "*")
        guard parts.count > 1 else {
            return Text(placeholder).foregroundStyle(placeholderColor).font(placeholderFont)
        }
        var result = Text(parts[0]).foregroundStyle(placeholderColor)
        for part in parts.dropFirst() {
            result = result + Text("*").foregroundStyle(Color.ftdDestructiveRed)
            if !part.isEmpty {
                result = result + Text(part).foregroundStyle(placeholderColor)
            }
        }
        return result.font(placeholderFont)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                if !label.isEmpty {
                    ftdRequiredLabel(label)
                        .font(.caption)
                }

                TextField(text: $text, prompt: buildPrompt()) {
                    Text(placeholder)
                }
                .font(.ftdBodySM)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .frame(maxWidth: .infinity)
            }
            .ftdInputContainer(hasError: errorMessage != nil)

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.ftdDestructiveRed)
                    .padding(.horizontal, DesignTokens.Spacing.xxs)
            }
        }
    }
}
