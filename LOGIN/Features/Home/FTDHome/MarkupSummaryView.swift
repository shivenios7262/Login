import SwiftUI

struct MarkupSummaryView: View {
    @Bindable var viewModel: MarkupsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ftdInputBackground.ignoresSafeArea()
                mainContent
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.ftdCardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "Markup Summary"))
                        .font(.ftdSectionHeaderMedium)
                        .foregroundStyle(Color.ftdTextPrimary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image("back")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color.ftdTextPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.ftdCardBackground)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "Close"))
                }
            }
            .alert(String(localized: "Error"), isPresented: Binding(
                get: { viewModel.saveError != nil },
                set: { if !$0 { viewModel.saveError = nil } }
            )) {
                Button(String(localized: "OK")) { viewModel.saveError = nil }
            } message: {
                Text(viewModel.saveError ?? "")
            }
        }
        .task { await viewModel.fetchMarkups() }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        if viewModel.isLoadingMarkups {
            loadingView
        } else if let error = viewModel.markupsError {
            errorView(error)
        } else {
            formContent
        }
    }

    private var formContent: some View {
        VStack(spacing: 0) {
            heroBanner
            tabBar
            ScrollView(showsIndicators: false) {
                VStack(spacing: DesignTokens.Spacing.lg) {
                    tabContent
                        .padding(.horizontal, DesignTokens.Spacing.lg)
                        .padding(.top, DesignTokens.Spacing.lg)
                        .padding(.bottom, DesignTokens.Spacing.xxxl)
                }
            }
        }
        .overlay {
            if viewModel.isSaving { loadingOverlay }
        }
        .overlay(alignment: .bottom) {
            if viewModel.saveSuccess { successToast }
        }
    }

    // MARK: - Hero Banner

    private var heroBanner: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(String(localized: "Markup Summary"))
                .font(.title2).fontWeight(.bold)
                .foregroundStyle(.white)
            Text(String(localized: "Manage your service markups"))
                .font(.caption)
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.bottom, DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity, minHeight: 130, maxHeight: 130, alignment: .bottomLeading)
        .background(
            FTDRemoteImage(
                url: FTDImageURL.myBookingsBanner,
                contentMode: .fill
            )
            .overlay(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.50)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        )
        .clipped()
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(MarkupTab.allCases) { tab in
                    tabItem(tab)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
        }
        .background(Color.ftdCardBackground)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.ftdBorder.opacity(0.5))
                .frame(height: 1)
        }
    }

    private func tabItem(_ tab: MarkupTab) -> some View {
        let isSelected = viewModel.selectedTab == tab
        return Button {
            withAnimation(.easeInOut(duration: DesignTokens.Animation.fast)) {
                viewModel.selectedTab = tab
            }
        } label: {
            VStack(spacing: DesignTokens.Spacing.xs) {
                Text(tab.rawValue)
                    .font(.ftdLabelSM)
                    .foregroundStyle(isSelected ? Color.ftdAccentOrange : Color.ftdTextSecondary)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.top, DesignTokens.Spacing.md)

                Rectangle()
                    .fill(isSelected ? Color.ftdAccentOrange : Color.clear)
                    .frame(height: 2)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .flight:  flightTab
        case .bus:     simpleMarkupTab(type: $viewModel.busType, value: $viewModel.busValue)
        case .cab:     simpleMarkupTab(type: $viewModel.cabType, value: $viewModel.cabValue)
        case .hotel:   hotelTab
        case .esim:    simpleMarkupTab(type: $viewModel.esimType, value: $viewModel.esimValue)
        }
    }

    // MARK: - Flight Tab

    private var flightTab: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            netToggleRow

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                Text(String(localized: "Flight Markup"))
                    .font(.subheadline).fontWeight(.semibold)
                    .foregroundStyle(Color.ftdTextPrimary)

                markupCard(title: "International",
                           type: $viewModel.flightIntType,
                           value: $viewModel.flightIntValue)

                markupCard(title: "Domestic",
                           type: $viewModel.flightDomType,
                           value: $viewModel.flightDomValue)
            }

//            HStack(alignment: .top, spacing: DesignTokens.Spacing.xs) {
//                Text(String(localized: "Note :"))
//                    .font(.caption).fontWeight(.semibold)
//                    .foregroundStyle(Color.ftdTextSecondary)
//                Text(String(localized: "If you do make any changes here you don't need to update specific airlines."))
//                    .font(.caption)
//                    .foregroundStyle(Color.ftdTextSecondary)
//            }
//            .padding(DesignTokens.Spacing.md)
//            .background(Color.ftdCardBackground)
//            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
//            .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.card).stroke(Color.ftdBorder, lineWidth: 1))

            saveButton
        }
    }

    private var netToggleRow: some View {
        HStack(spacing: DesignTokens.Spacing.lg) {
            radioOption(title: "Show Net", isSelected: viewModel.showNet) {
                viewModel.showNet = true
            }
            radioOption(title: "Hide Net", isSelected: !viewModel.showNet) {
                viewModel.showNet = false
            }
            Spacer()
            saveButton
                .frame(width: 100)
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.card).stroke(Color.ftdBorder, lineWidth: 1))
    }

    private func radioOption(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.ftdAccentOrange : Color.ftdBorder, lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                    if isSelected {
                        Circle()
                            .fill(Color.ftdAccentOrange)
                            .frame(width: 10, height: 10)
                    }
                }
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextPrimary)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: isSelected)
    }

    // MARK: - Markup Card

    private func markupCard(title: String,
                            type: Binding<MarkupType>,
                            value: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(title)
                .font(.ftdLabelSM)
                .foregroundStyle(Color.ftdTextPrimary)

            HStack(spacing: DesignTokens.Spacing.md) {
                FTDDropdownField(
                    label: "Type",
                    placeholder: "Select Type",
                    selection: type,
                    options: MarkupType.allCases,
                    optionLabel: { $0.rawValue }
                )

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                    Text(String(localized: "Value"))
                        .font(.ftdPlaceholder)
                        .foregroundStyle(Color.ftdTextTertiary)
                    TextField("0", text: value)
                        .keyboardType(.numberPad)
                        .font(.ftdBodySM)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, DesignTokens.Spacing.inputHorizontal)
                .padding(.top, DesignTokens.Spacing.inputVertical)
                .frame(minHeight: DesignTokens.Spacing.inputFieldHeight, alignment: .top)
                .background(Color.ftdCardBackground, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .stroke(Color.ftdBorder, lineWidth: 1)
                )
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.ftdInputBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
    }

    // MARK: - Simple Markup Tab (Bus / Cab / eSIM)

    private func simpleMarkupTab(type: Binding<MarkupType>, value: Binding<String>) -> some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            VStack(spacing: DesignTokens.Spacing.md) {
                FTDDropdownField(
                    label: "Markup Type",
                    placeholder: "Select Type",
                    selection: type,
                    options: MarkupType.allCases,
                    optionLabel: { $0.rawValue }
                )

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                    Text(String(localized: "Markup Value"))
                        .font(.ftdPlaceholder)
                        .foregroundStyle(Color.ftdTextTertiary)
                    TextField("0", text: value)
                        .keyboardType(.numberPad)
                        .font(.ftdBodySM)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, DesignTokens.Spacing.inputHorizontal)
                .padding(.top, DesignTokens.Spacing.inputVertical)
                .frame(minHeight: DesignTokens.Spacing.inputFieldHeight, alignment: .top)
                .background(Color.ftdCardBackground, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .stroke(Color.ftdBorder, lineWidth: 1)
                )
            }
            .padding(DesignTokens.Spacing.lg)
            .background(Color.ftdCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)

            saveButton
        }
    }

    // MARK: - Hotel Tab

    private var hotelTab: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            VStack(spacing: DesignTokens.Spacing.md) {
                hotelRow(
                    typeLabel:  "Domestic",
                    markupType: $viewModel.hotelDomType,
                    value:      $viewModel.hotelDomValue
                )

                Divider().overlay(Color.ftdBorder.opacity(0.5))

                hotelRow(
                    typeLabel:  "International",
                    markupType: $viewModel.hotelIntType,
                    value:      $viewModel.hotelIntValue
                )
            }
            .padding(DesignTokens.Spacing.lg)
            .background(Color.ftdCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)

            saveButton
        }
    }

    private func hotelRow(typeLabel: String,
                          markupType: Binding<MarkupType>,
                          value: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text(String(localized: "Type"))
                        .font(.caption2).foregroundStyle(Color.ftdTextSecondary)
                    Text(typeLabel)
                        .font(.ftdLabelSM).foregroundStyle(Color.ftdTextPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                FTDDropdownField(
                    label: "Markup Type",
                    placeholder: "Select Type",
                    selection: markupType,
                    options: MarkupType.allCases,
                    optionLabel: { $0.rawValue }
                )
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                Text(String(localized: "Markup Value"))
                    .font(.ftdPlaceholder)
                    .foregroundStyle(Color.ftdTextTertiary)
                TextField("0", text: value)
                    .keyboardType(.numberPad)
                    .font(.ftdBodySM)
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, DesignTokens.Spacing.inputHorizontal)
            .padding(.top, DesignTokens.Spacing.inputVertical)
            .frame(minHeight: DesignTokens.Spacing.inputFieldHeight, alignment: .top)
            .background(Color.ftdInputBackground, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                    .stroke(Color.ftdBorder, lineWidth: 1)
            )
        }
    }

    // MARK: - Save Button

    private var saveButton: some View {
        FTDPrimaryButton(
            title: String(localized: "Save"),
            isLoading: viewModel.isSaving
        ) {
            Task { await viewModel.save() }
        }
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.30).ignoresSafeArea()
            VStack(spacing: DesignTokens.Spacing.lg) {
                ProgressView()
                    .tint(Color.ftdAccentOrange)
                    .scaleEffect(1.5)
                Text(String(localized: "Saving..."))
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .padding(DesignTokens.Spacing.xxl)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.cardLg))
        }
    }

    // MARK: - Success Toast

    private var successToast: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.ftdAccentTeal)
            Text(String(localized: "Markup saved successfully"))
                .font(.ftdLabelMD)
                .foregroundStyle(Color.ftdTextPrimary)
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
        .shadow(color: .black.opacity(0.12), radius: 10, y: 4)
        .padding(.bottom, DesignTokens.Spacing.xxl)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                withAnimation { viewModel.saveSuccess = false }
            }
        }
    }

    // MARK: - Error / Loading views

    private var loadingView: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            ProgressView().tint(Color.ftdAccentOrange).scaleEffect(1.5)
            Text(String(localized: "Loading markups..."))
                .font(.subheadline).foregroundStyle(Color.ftdTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Spacer()
            Image(systemName: "exclamationmark.triangle")
                .font(.ftdHeroIcon).foregroundStyle(Color.ftdAccentOrange.opacity(0.6))
            Text(message)
                .font(.subheadline).multilineTextAlignment(.center)
                .foregroundStyle(Color.ftdTextSecondary)
                .padding(.horizontal, DesignTokens.Spacing.xxl)
            Button(String(localized: "Retry")) { Task { await viewModel.fetchMarkups() } }
                .buttonStyle(.borderedProminent).tint(Color.ftdAccentOrange)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
