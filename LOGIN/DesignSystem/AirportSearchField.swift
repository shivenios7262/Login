import SwiftUI

struct AirportSearchField: View {
    let label: String
    let placeholder: String
    @Binding var selection: AirportItem
    let airports: [AirportItem]
    var errorMessage: String? = nil

    @State private var searchText = ""
    @FocusState private var isFocused: Bool

    private var showDropdown: Bool { isFocused && searchText.count >= 3 }

    private var filteredAirports: [AirportItem] {
        guard searchText.count >= 3 else { return [] }
        let q = searchText.lowercased()
        return Array(
            airports.filter {
                $0.label.lowercased().contains(q) || $0.city.lowercased().contains(q)
            }
            .prefix(12)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                ftdRequiredLabel(label).font(.caption)

                HStack(spacing: DesignTokens.Spacing.xs) {
                    TextField(placeholder, text: $searchText)
                        .focused($isFocused)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .font(.ftdBodySM)
                        .frame(maxWidth: .infinity)
                        .overlay(alignment: .leading) {
                            // Cover the empty TextField with the selected value when not editing
                            if !isFocused && selection != .empty {
                                Text(selection.displayLabel)
                                    .font(.ftdBodySM)
                                    .foregroundStyle(Color.ftdTextPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.75)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.ftdCardBackground)
                                    .allowsHitTesting(false)
                            }
                        }

                    if selection != .empty && !isFocused {
                        Button {
                            selection = .empty
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(Color.ftdTextSecondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .ftdInputContainer(hasError: errorMessage != nil)

            if showDropdown {
                dropdownList
            }

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.ftdDestructiveRed)
                    .padding(.horizontal, DesignTokens.Spacing.xxs)
            }
        }
        .onChange(of: isFocused) { _, _ in
            searchText = ""
        }
    }

    private var dropdownList: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                if filteredAirports.isEmpty {
                    Text("No airport found")
                        .font(.subheadline)
                        .foregroundStyle(Color.ftdTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(DesignTokens.Spacing.md)
                } else {
                    ForEach(filteredAirports) { airport in
                        Button {
                            selection = airport
                            searchText = ""
                            isFocused = false
                        } label: {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(airport.label)
                                    .font(.ftdBodySM)
                                    .foregroundStyle(Color.ftdTextPrimary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                if !airport.city.isEmpty {
                                    Text(airport.city)
                                        .font(.caption)
                                        .foregroundStyle(Color.ftdTextSecondary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding(.horizontal, DesignTokens.Spacing.md)
                            .padding(.vertical, DesignTokens.Spacing.sm)
                        }
                        .buttonStyle(.plain)

                        Divider()
                            .background(Color.ftdBorder.opacity(0.5))
                    }
                }
            }
        }
        .frame(maxHeight: 200)
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
        .shadow(color: .black.opacity(0.12), radius: 6, y: 3)
    }
}
