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
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color("TextSecondary"))

            Button {
                isPresented = true
            } label: {
                HStack {
                    let displayText = optionLabel(selection)
                    Text(displayText.isEmpty ? placeholder : displayText)
                        .foregroundStyle(
                            displayText.isEmpty ? Color("TextSecondary") : Color("TextPrimary")
                        )
                    Spacer()
                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundStyle(Color("TextSecondary"))
                }
                .padding(.vertical, 10)
                .contentShape(Rectangle())
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
        .sheet(isPresented: $isPresented) {
            NavigationStack {
                List(options, id: \.self) { option in
                    Button {
                        selection = option
                        isPresented = false
                    } label: {
                        HStack {
                            Text(optionLabel(option))
                                .foregroundStyle(Color("TextPrimary"))
                            Spacer()
                            Image(
                                systemName: selection == option
                                    ? "checkmark.circle.fill"
                                    : "circle"
                            )
                            .foregroundStyle(
                                selection == option ? Color("AccentOrange") : Color("BorderColor")
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
                        .foregroundStyle(Color("AccentOrange"))
                    }
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}
