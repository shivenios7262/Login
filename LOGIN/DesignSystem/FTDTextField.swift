import SwiftUI

struct FTDTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var errorMessage: String?
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .sentences

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))

            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .textInputAutocapitalization(autocapitalization)
                .autocorrectionDisabled()
                .padding(.vertical, 10)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(
                            errorMessage != nil ? Color("DestructiveRed") : Color("BorderColor")
                        )
                }

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color("DestructiveRed"))
            }
        }
    }
}
