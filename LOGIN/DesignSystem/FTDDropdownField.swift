import SwiftUI

/*
#Preview("Field") {
    struct PreviewWrapper: View {
        @State private var selection = "Travel Agent"
        let options = ["Travel Agent", "Customer", "Distributor", "Sales"]
        let icons = ["building.2", "person", "storefront", "bag"]

        var body: some View {
            VStack {
                FTDDropdownField(
                    label: "User Type",
                    placeholder: "Choose User Type",
                    selection: $selection,
                    options: options,
                    optionLabel: { $0 },
                    optionIcon: { opt in
                        icons[options.firstIndex(of: opt) ?? 0]
                    }
                )
                .padding()
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    return PreviewWrapper()
}

#Preview("Sheet") {
    struct SheetPreview: View {
        @State private var selection = "Travel Agent"
        let options = ["Travel Agent", "Customer", "Distributor", "Sales"]
        let icons = ["building.2", "person", "storefront", "bag"]

        var body: some View {
            VStack(spacing: 0) {
                HStack(alignment: .center) {
                    Text("User Type")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.ftdTextPrimary)
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.ftdTextPrimary)
                        .padding(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.ftdBorder, lineWidth: 1.5))
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Divider()
                    .opacity(0.35)

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(zip(options, icons)), id: \.0) { option, icon in
                            HStack(spacing: 14) {
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .foregroundStyle(selection == option ? Color.ftdAccentOrange : Color.ftdTextSecondary)
                                    .frame(width: 28, height: 28)
                                Text(option)
                                    .font(.body)
                                    .foregroundStyle(Color.ftdTextPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                ZStack {
                                    Circle()
                                        .stroke(selection == option ? Color.ftdAccentOrange : Color.ftdBorder, lineWidth: 1.5)
                                        .frame(width: 22, height: 22)
                                    if selection == option {
                                        Circle()
                                            .fill(Color.ftdAccentOrange)
                                            .frame(width: 12, height: 12)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(
                                Group {
                                    if selection == option {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.ftdAccentOrange.opacity(0.08))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }
    return SheetPreview()
}
*/

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
                    ftdRequiredLabel(label)
                        .font(.caption)

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
                    Text(label.replacingOccurrences(of: "*", with: "").trimmingCharacters(in: .whitespaces))
                        .font(.ftdSectionHeaderMedium)
                        .foregroundStyle(Color.ftdTextPrimary)

                    Spacer()

                    Button {
                        isPresented = false
                    } label: {
                        // SF Symbol alternative:
                        // Image(systemName: "checkmark")
                        //     .font(.body.weight(.semibold))
                        //     .foregroundStyle(Color.ftdTextPrimary)
                        //     .padding(10)
                        //     .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.ftdBorder, lineWidth: 1.5))
                        Image("checkmark")
                            .font(.body.weight(.semibold))
                            .foregroundStyle(Color.ftdTextPrimary)
                            .padding(10)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 16)

                Divider()
                    //.opacity(0.95)
                    .background(Color.ftdTextSecondary)

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(options, id: \.self) { option in
                            Button {
                                selection = option
                            } label: {
                                HStack(spacing: 14) {
                                    if let iconName = optionIcon?(option) {
                                        Image(iconName)
                                            .renderingMode(.template)
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundStyle(
                                                selection == option ? Color.ftdAccentOrange : Color.black
                                            )
                                            .frame(width: 24, height: 24)
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
                                .padding(.vertical, 14)
                                .background(
                                    Group {
                                        if selection == option {
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.ftdAccentOrange.opacity(0.08))
                                                .padding(.horizontal, 10)
                                                .padding(.vertical, 4)
                                        }
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationBackground(.white)
        }
    }
}
