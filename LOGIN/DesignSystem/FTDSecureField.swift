import SwiftUI

struct FTDSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    var errorMessage: String?
    var placeholderColor: Color = Color.ftdTextSecondary
    var placeholderFont: Font = Font.ftdPlaceholder

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

                HStack(spacing: DesignTokens.Spacing.xs) {
                    Group {
                        let prompt = buildPrompt()
                        if isVisible {
                            TextField(text: $text, prompt: prompt) {
                                Text(placeholder)
                            }
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        } else {
                            SecureField(text: $text, prompt: prompt) {
                                Text(placeholder)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)

                    Button {
                        isVisible.toggle()
                    } label: {
                        Image(systemName: isVisible ? "eye.slash" : "eye")
                            .foregroundStyle(Color.ftdTextSecondary)
                            .font(.ftdIconEye)
                    }
                }
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
