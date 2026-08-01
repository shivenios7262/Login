import SwiftUI

struct FTDDropdownField<T: Hashable>: View {
    let label: String
    let placeholder: String
    @Binding var selection: T
    let options: [T]
    let optionLabel: (T) -> String
    var errorMessage: String?

    @State private var isPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Button {
                isPresented = true
            } label: {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                    Text(label)
                        .font(.caption)
                        .foregroundStyle(Color.ftdTextSecondary)

                    HStack(spacing: DesignTokens.Spacing.xs) {
                        let displayText = optionLabel(selection)
                        Text(displayText.isEmpty ? placeholder : displayText)
                            .foregroundStyle(
                                displayText.isEmpty ? Color.ftdTextSecondary : Color.ftdTextPrimary
                            )
                            .frame(maxWidth: .infinity, alignment: .leading)

                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundStyle(Color.ftdTextSecondary)
                    }
                }
                .ftdInputContainer(hasError: errorMessage != nil)
                .background(Color.ftdCardBackground, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.ftdDestructiveRed)
                    .padding(.horizontal, DesignTokens.Spacing.xxs)
            }
        }
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                List(options, id: \.self) { option in
                    Button {
                        selection = option
                        isPresented = false
                    } label: {
                        HStack {
                            Text(optionLabel(option))
                                .foregroundStyle(Color.ftdTextPrimary)
                            Spacer()
                            Image(
                                systemName: selection == option
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )
                            .foregroundStyle(
                                selection == option ? Color.ftdAccentOrange : Color.ftdBorder
                            )
                        }
                    }
                }
                .listStyle(.plain)
                .navigationTitle(Text(label))
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "Cancel")) {
                            isPresented = false
                        }
                        .foregroundStyle(Color.ftdAccentOrange)
                    }
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}
