import SwiftUI

struct FTDSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                if !label.isEmpty {
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(Color.ftdTextSecondary)
                }

                HStack(spacing: DesignTokens.Spacing.sm) {
                    Group {
                        if isVisible {
                            TextField(placeholder, text: $text)
                                .textInputAutocapitalization(.never)
                                .autocorrectionDisabled()
                        } else {
                            SecureField(placeholder, text: $text)
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
