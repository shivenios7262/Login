import SwiftUI

struct FTDTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var errorMessage: String?
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                if !label.isEmpty {
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(Color.ftdTextSecondary)
                }

                TextField(placeholder, text: $text)
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
