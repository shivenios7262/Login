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
    var searchable: Bool = false

    @State private var isPresented = false
    @State private var searchQuery = ""

    private var filteredOptions: [T] {
        guard searchable, !searchQuery.isEmpty else { return options }
        let q = searchQuery.lowercased()
        return options.filter { optionLabel($0).lowercased().contains(q) }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Button {
                isPresented = true
            } label: {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                    ftdRequiredLabel(label)
                        .font(.ftdPlaceholder)

                    let displayText = optionLabel(selection)
                    Text(displayText.isEmpty ? placeholder : displayText)
                        .foregroundStyle(
                            displayText.isEmpty ? Color.ftdTextSecondary : Color.ftdTextPrimary
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.ftdBodySM)
                }
                .padding(.horizontal, DesignTokens.Spacing.inputHorizontal)
                .padding(.top, DesignTokens.Spacing.inputVertical)
                .frame(minHeight: DesignTokens.Spacing.inputFieldHeight, alignment: .top)
                .background(Color.ftdCardBackground, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .stroke(errorMessage != nil ? Color.ftdDestructiveRed : Color.ftdBorder, lineWidth: 1)
                )
                .overlay(alignment: .trailing) {
                    Image("chevron.down")
                        .font(.ftdPlaceholder)
                        .foregroundStyle(Color.ftdTextSecondary)
                        .padding(.trailing, DesignTokens.Spacing.inputHorizontal)
                }
                .frame(maxWidth: .infinity)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if let error = errorMessage {
                Text(error)
                    .font(.ftdPlaceholder)
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
                    .background(Color.ftdTextSecondary)

                if searchable {
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(Color.ftdTextSecondary)
                        TextField("Search…", text: $searchQuery)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                        if !searchQuery.isEmpty {
                            Button { searchQuery = "" } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(Color.ftdTextSecondary)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.ftdInputBackground)

                    Divider().background(Color.ftdTextSecondary)
                }

                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(filteredOptions, id: \.self) { option in
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
                                                selection == option ? Color.ftdAccentOrange : Color.ftdTextSecondary
                                            )
                                            .frame(width: 24, height: 24)
                                    }

                                    Text(optionLabel(option))
                                        .font(.ftdIconEye)
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
                                .contentShape(Rectangle())
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 8)

                    if searchable && filteredOptions.isEmpty {
                        Text("No results for \"\(searchQuery)\"")
                            .font(.subheadline)
                            .foregroundStyle(Color.ftdTextSecondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.vertical, DesignTokens.Spacing.xl)
                    }
                }
            }
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
            .presentationBackground(Color.ftdCardBackground)
            .onDisappear { searchQuery = "" }
        }
    }
}
