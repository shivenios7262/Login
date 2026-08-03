import SwiftUI

struct FTDDropdownField<T: Hashable>: View {
    let label: String
    let placeholder: String
    @Binding var selection: T
    let options: [T]
    let optionLabel: (T) -> String
    var optionIcon: ((T) -> String)?
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
                            .padding(.trailing, DesignTokens.Spacing.inputHorizontal)
                            .padding(.bottom)
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
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Text(label)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.ftdTextPrimary)

                    Spacer()

                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "checkmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.ftdTextPrimary)
                            .padding(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.ftdBorder, lineWidth: 1.5)
                            )
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Divider()

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(options, id: \.self) { option in
                            Button {
                                selection = option
                            } label: {
                                HStack(spacing: 14) {
                                    if let iconName = optionIcon?(option) {
                                        Image(systemName: iconName)
                                            .font(.system(size: 20))
                                            .foregroundStyle(
                                                selection == option ? Color.ftdAccentOrange : Color.ftdTextSecondary
                                            )
                                            .frame(width: 28, height: 28)
                                    }

                                    Text(optionLabel(option))
                                        .font(.body)
                                        .foregroundStyle(Color.ftdTextPrimary)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    ZStack {
                                        Circle()
                                            .stroke(
                                                selection == option ? Color.ftdAccentOrange : Color.ftdBorder,
                                                lineWidth: 1.5
                                            )
                                            .frame(width: 22, height: 22)
                                        if selection == option {
                                            Circle()
                                                .fill(Color.ftdAccentOrange)
                                                .frame(width: 12, height: 12)
                                        }
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                                .background(
                                    selection == option
                                        ? Color.ftdAccentOrange.opacity(0.08)
                                        : Color.clear
                                )
                            }
                            .buttonStyle(.plain)

                            Divider()
                                .padding(.leading, optionIcon != nil ? 62 : 20)
                        }
                    }
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
    }
}
