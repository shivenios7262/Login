import SwiftUI

struct FTDSecureField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    @Binding var isVisible: Bool
    var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))

            HStack(spacing: 4) {
                Group {
                    if isVisible {
                        TextField(placeholder, text: $text)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } else {
                        SecureField(placeholder, text: $text)
                    }
                }
                .padding(.vertical, 10)

                Button {
                    isVisible.toggle()
                } label: {
                    Image(systemName: isVisible ? "eye.slash" : "eye")
                        .foregroundStyle(Color("TextSecondary"))
                        .font(.system(size: 16))
                }
            }
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
