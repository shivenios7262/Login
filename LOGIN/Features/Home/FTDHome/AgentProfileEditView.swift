import SwiftUI
import PhotosUI

struct AgentProfileEditView: View {
    @Bindable var viewModel: AgentProfileEditViewModel

    @State private var isCurrentPwdVisible  = false
    @State private var isNewPwdVisible      = false
    @State private var isConfirmPwdVisible  = false
    @State private var selectedLogoItem: PhotosPickerItem? = nil
    @State private var selectedLogoImage: Image? = nil
    @State private var selectedLogoFileName: String? = nil
    @State private var isGSTFormExpanded            = false
    @State private var isTravellerFormExpanded      = false
    @State private var isPasswordFormExpanded       = false
    @State private var showCertificatePreview       = false
    @State private var isGeneratingCertificate      = false
    @State private var certificateURL: URL?
    @State private var certImages                   = CertificateImages()
    @State private var showTravellerDOBPicker        = false
    @State private var showTravellerExpiryPicker     = false

    private static let dobDisplayFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd-MMM-yyyy"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    var body: some View {
        VStack(spacing: 0) {
            heroHeader
            customTabBar
            ScrollView(showsIndicators: false) {
                tabContent
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.top, DesignTokens.Spacing.lg)
                    .padding(.bottom, DesignTokens.Spacing.xxxl)
            }
            .background(Color.ftdInputBackground)
            floatingMultiDeleteBar
        }
        .background(Color.ftdInputBackground)
        .navigationTitle("Agent Details")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.loadProfile() }
    }

    // MARK: - Hero Header

    private var heroHeader: some View {
        ZStack(alignment: .topTrailing) {
            FTDRemoteImage(
                url: FTDImageURL.agentProfileBG,
                contentMode: .fill
            )
            .frame(maxWidth: .infinity, minHeight: 90, maxHeight: 90)
            .clipped()

            Button {
                showCertificatePreview = true
            } label: {
                HStack(spacing: DesignTokens.Spacing.xxs) {
                    Text("Download Certificate")
                        .font(.caption).fontWeight(.medium)
                        .underline()
                    Image(systemName: "arrow.down.to.line.compact")
                        .font(.caption)
                }
                .foregroundStyle(Color.ftdAccentOrange)
            }
            .padding(.trailing, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.lg)
            .sheet(isPresented: $showCertificatePreview) {
                certificatePreviewSheet
            }
        }
        .frame(height: 90)
        .clipped()
    }

    // MARK: - Pill Tab Bar

    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(AgentProfileTab.allCases) { tab in
                let isSelected = viewModel.selectedTab == tab
                Button { viewModel.selectedTab = tab } label: {
                    Text(tab.rawValue)
                        .font(.ftdLabelMD)
                        .foregroundStyle(isSelected ? Color.ftdAccentOrange : Color.ftdTextSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(isSelected ? Color.ftdCardBackground : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                                .stroke(isSelected ? Color.ftdAccentOrange : Color.clear, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DesignTokens.Spacing.xxs)
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.button)
                .stroke(Color.ftdAccentOrangeAlpha, lineWidth: 1)
        )
        .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: viewModel.selectedTab)
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
    }

    // MARK: - Tab Content Router

    @ViewBuilder
    private var tabContent: some View {
        switch viewModel.selectedTab {
        case .agentProfile: agentProfileTab
        case .traveller:    travellerTab
        case .gst:          gstTab
        }
    }

    // MARK: - Agent Profile Tab

    private var agentProfileTab: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Personal Information card
            formCard {
                sectionTitle("Agent Details")
                subsectionLabel("Personal Information")

                FTDDropdownField(
                    label: "Title*",
                    placeholder: "Select",
                    selection: $viewModel.title,
                    options: viewModel.titleOptions,
                    optionLabel: { $0 }
                )
                FTDTextField(label: "First Name*",  placeholder: "First Name*", text: $viewModel.firstName)
                FTDTextField(label: "Last Name",    placeholder: "Last Name",   text: $viewModel.lastName)
                FTDTextField(label: "Designation",  placeholder: "Designation", text: $viewModel.designation)
                FTDTextField(
                    label: "Website",
                    placeholder: "Website",
                    text: $viewModel.website,
                    keyboardType: .URL,
                    autocapitalization: .never
                )

                readOnlyField(label: "PAN No*",                value: viewModel.panNo.isEmpty ? "—" : viewModel.panNo)
                readOnlyField(label: "Name on PAN card*",      value: viewModel.namePanCard.isEmpty ? viewModel.agencyName : viewModel.namePanCard)
                readOnlyField(label: "Aadhar Number",          value: viewModel.aadharNo.isEmpty ? "—" : viewModel.aadharNo)
                readOnlyField(label: "Agency / Company Name*", value: viewModel.agencyName.isEmpty ? "—" : viewModel.agencyName)

                agencyLogoSection
            }

            // Contact Information card
            formCard {
                subsectionLabel("Contact Information")

                readOnlyField(label: "Contact Number*", value: viewModel.contactNo.isEmpty ? "—" : viewModel.contactNo)
                FTDTextField(
                    label: "Alternate Number",
                    placeholder: "Alternate Number",
                    text: $viewModel.officePhone,
                    keyboardType: .phonePad
                )
                FTDTextField(label: "Address*",      placeholder: "Address*",      text: $viewModel.address, autocapitalization: .sentences)
                FTDTextField(label: "City*",         placeholder: "City*",         text: $viewModel.city)
                FTDTextField(label: "State*",        placeholder: "State*",        text: $viewModel.state)
                FTDTextField(
                    label: "Postal Code*",
                    placeholder: "Postal Code*",
                    text: $viewModel.pinCode,
                    keyboardType: .numberPad
                )
                FTDTextField(label: "Country*", placeholder: "Country*", text: $viewModel.country)
            }

            // Update button
            VStack(spacing: DesignTokens.Spacing.sm) {
                if let msg = viewModel.profileMessage {
                    statusMessage(msg, isError: viewModel.profileMessageIsError)
                }
                FTDPrimaryButton(title: "UPDATE", isLoading: viewModel.isUpdatingProfile) {
                    Task { await viewModel.updateProfile() }
                }
            }

            // Collapsible Reset Password card
            VStack(alignment: .leading, spacing: 0) {
                Button {
                    withAnimation(.easeInOut(duration: DesignTokens.Animation.standard)) {
                        isPasswordFormExpanded.toggle()
                        if !isPasswordFormExpanded { viewModel.passwordMessage = nil }
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Reset Password")
                                .font(.headline).fontWeight(.bold)
                                .foregroundStyle(Color.ftdTextPrimary)
                            if !isPasswordFormExpanded {
                                Text("Tap to change your password")
                                    .font(.caption)
                                    .foregroundStyle(Color.ftdTextSecondary)
                            }
                        }
                        Spacer()
                        if !isPasswordFormExpanded {
                            Label("Change", systemImage: "lock.rotation")
                                .font(.subheadline).fontWeight(.semibold)
                                .foregroundStyle(Color.ftdAccentOrange)
                                .labelStyle(.titleAndIcon)
                        } else {
                            Image(systemName: "chevron.up")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.ftdTextSecondary)
                        }
                    }
                    .padding(DesignTokens.Spacing.lg)
                }
                .buttonStyle(.plain)

                if isPasswordFormExpanded {
                    Divider().padding(.horizontal, DesignTokens.Spacing.lg)

                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                        FTDSecureField(
                            label: "Current Password*",
                            placeholder: "Current Password*",
                            text: $viewModel.currentPassword,
                            isVisible: $isCurrentPwdVisible
                        )
                        FTDSecureField(
                            label: "New Password*",
                            placeholder: "New Password*",
                            text: $viewModel.newPassword,
                            isVisible: $isNewPwdVisible
                        )
                        FTDSecureField(
                            label: "Confirm Password*",
                            placeholder: "Confirm Password*",
                            text: $viewModel.confirmPassword,
                            isVisible: $isConfirmPwdVisible
                        )

                        if let msg = viewModel.passwordMessage {
                            statusMessage(msg, isError: viewModel.passwordMessageIsError)
                        }

                        Button {
                            Task {
                                await viewModel.changePassword()
                                if !viewModel.passwordMessageIsError {
                                    withAnimation(.easeInOut(duration: DesignTokens.Animation.standard)) {
                                        isPasswordFormExpanded = false
                                    }
                                }
                            }
                        } label: {
                            ZStack {
                                if viewModel.isChangingPassword {
                                    ProgressView().tint(Color.ftdAccentOrange)
                                } else {
                                    Text("Reset Password")
                                        .font(.subheadline).fontWeight(.semibold)
                                        .foregroundStyle(Color.ftdAccentOrange)
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 44)
                            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignTokens.Radius.button)
                                    .stroke(Color.ftdAccentOrange, lineWidth: 1.5)
                            )
                        }
                        .disabled(viewModel.isChangingPassword)
                        .buttonStyle(.plain)
                    }
                    .padding(DesignTokens.Spacing.lg)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(Color.ftdCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        }
    }

    // MARK: - Traveller Tab

    private var travellerTab: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Collapsible Add / Edit form
            VStack(alignment: .leading, spacing: 0) {
                // Header row
                Button {
                    withAnimation(.easeInOut(duration: DesignTokens.Animation.standard)) {
                        if isTravellerFormExpanded {
                            isTravellerFormExpanded = false
                            viewModel.cancelTravellerEdit()
                        } else {
                            isTravellerFormExpanded = true
                        }
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(viewModel.editingTravellerId == nil ? "Add Traveller" : "Edit Traveller Details")
                                .font(.headline).fontWeight(.bold)
                                .foregroundStyle(Color.ftdTextPrimary)
                            if !isTravellerFormExpanded {
                                Text(viewModel.editingTravellerId == nil ? "Tap to add a traveller" : "Tap to edit traveller")
                                    .font(.caption)
                                    .foregroundStyle(Color.ftdTextSecondary)
                            }
                        }
                        Spacer()
                        if !isTravellerFormExpanded {
                            Label("Add Traveller", systemImage: "person.badge.plus")
                                .font(.subheadline).fontWeight(.semibold)
                                .foregroundStyle(Color.ftdAccentOrange)
                                .labelStyle(.titleAndIcon)
                        } else {
                            Image(systemName: "chevron.up")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.ftdTextSecondary)
                        }
                    }
                    .padding(DesignTokens.Spacing.lg)
                }
                .buttonStyle(.plain)

                if isTravellerFormExpanded {
                    Divider().padding(.horizontal, DesignTokens.Spacing.lg)

                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                        // ── Personal Information ──────────────────────────
                        subsectionLabel("Personal Information")

                        HStack(spacing: DesignTokens.Spacing.md) {
                            FTDDropdownField(
                                label: "Pax Type",
                                placeholder: "Adult",
                                selection: $viewModel.travellerPaxType,
                                options: viewModel.paxTypeOptions,
                                optionLabel: { $0 }
                            )
                            FTDDropdownField(
                                label: "Title",
                                placeholder: "Select",
                                selection: $viewModel.travellerTitle,
                                options: ["", "Mr.", "Mrs.", "Ms."/*, "Master", "Miss"*/],
                                optionLabel: { $0.isEmpty ? "Select" : $0 }
                            )
                        }

                        HStack(spacing: DesignTokens.Spacing.md) {
                            FTDTextField(label: "First Name*", placeholder: "First Name", text: $viewModel.travellerFirstName)
                            FTDTextField(label: "Last Name",   placeholder: "Last Name",  text: $viewModel.travellerLastName)
                        }

                        Button { showTravellerDOBPicker = true } label: {
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                                ftdRequiredLabel("DOB").font(.caption)
                                HStack {
                                    Text(Self.dobDisplayFmt.string(from: viewModel.travellerDOBDate))
                                        .font(.ftdBodySM)
                                        .foregroundStyle(Color.ftdTextPrimary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Image(systemName: "calendar")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color.ftdAccentOrange)
                                }
                            }
                            .ftdInputContainer()
                        }
                        .buttonStyle(.plain)
                        .sheet(isPresented: $showTravellerDOBPicker) {
                            dobPickerSheet
                        }

                        // ── Passport Information ──────────────────────────
                        subsectionLabel("Passport Information")

                        if viewModel.countryOptions.isEmpty {
                            FTDTextField(label: "Nationality", placeholder: "Nationality", text: $viewModel.travellerNationality)
                        } else {
                            FTDDropdownField(
                                label: "Nationality",
                                placeholder: "Select Nationality",
                                selection: $viewModel.travellerNationality,
                                options: viewModel.countryOptions,
                                optionLabel: { $0 },
                                searchable: true
                            )
                        }

                        FTDTextField(
                            label: "Passport Number",
                            placeholder: "Passport Number",
                            text: $viewModel.travellerPassport,
                            autocapitalization: .characters
                        )

                        if viewModel.countryOptions.isEmpty {
                            FTDTextField(label: "Issuing Country", placeholder: "Issuing Country", text: $viewModel.travellerIssueCountry)
                        } else {
                            FTDDropdownField(
                                label: "Issuing Country",
                                placeholder: "Select Country",
                                selection: $viewModel.travellerIssueCountry,
                                options: viewModel.countryOptions,
                                optionLabel: { $0 },
                                searchable: true
                            )
                        }

                        Button { showTravellerExpiryPicker = true } label: {
                            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                                ftdRequiredLabel("Expiry Date").font(.caption)
                                HStack {
                                    Text(Self.dobDisplayFmt.string(from: viewModel.travellerExpiryDateObj))
                                        .font(.ftdBodySM)
                                        .foregroundStyle(Color.ftdTextPrimary)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                    Image(systemName: "calendar")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color.ftdAccentOrange)
                                }
                            }
                            .ftdInputContainer()
                        }
                        .buttonStyle(.plain)
                        .sheet(isPresented: $showTravellerExpiryPicker) {
                            expiryPickerSheet
                        }

                        HStack(spacing: DesignTokens.Spacing.md) {
                            FTDTextField(
                                label: "Age",
                                placeholder: "Age",
                                text: $viewModel.travellerAge,
                                keyboardType: .numberPad
                            )
                            FTDDropdownField(
                                label: "Gender",
                                placeholder: "Select",
                                selection: $viewModel.travellerGender,
                                options: viewModel.genderOptions,
                                optionLabel: { $0 }
                            )
                        }

                        if let msg = viewModel.travellerMessage {
                            statusMessage(msg, isError: viewModel.travellerMessageIsError)
                        }

                        FTDPrimaryButton(
                            title: viewModel.editingTravellerId == nil ? "ADD TRAVELLER" : "UPDATE",
                            isLoading: viewModel.isAddingTraveller
                        ) {
                            Task {
                                await viewModel.submitTraveller()
                                if !viewModel.travellerMessageIsError {
                                    withAnimation(.easeInOut(duration: DesignTokens.Animation.standard)) {
                                        isTravellerFormExpanded = false
                                    }
                                }
                            }
                        }

                        if viewModel.editingTravellerId != nil {
                            Button {
                                withAnimation(.easeInOut(duration: DesignTokens.Animation.standard)) {
                                    viewModel.cancelTravellerEdit()
                                    isTravellerFormExpanded = false
                                }
                            } label: {
                                Text("CANCEL")
                                    .font(.subheadline).fontWeight(.semibold)
                                    .foregroundStyle(Color.ftdAccentTeal)
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignTokens.Radius.button)
                                            .stroke(Color.ftdAccentTeal, lineWidth: 1.5)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(DesignTokens.Spacing.lg)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(Color.ftdCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
            .onChange(of: viewModel.editingTravellerId) { _, newId in
                if newId != nil {
                    withAnimation(.easeInOut(duration: DesignTokens.Animation.standard)) {
                        isTravellerFormExpanded = true
                    }
                }
            }

            // Traveller list
            if !viewModel.travellerList.isEmpty {
                travellerListSection
            }
        }
    }

    // MARK: - Traveller List

    private var travellerListSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                Text("Your Travellers Information")
                    .font(.headline).fontWeight(.bold)
                    .foregroundStyle(Color.ftdTextPrimary)
                Spacer()
                Button(viewModel.isTravellerMultiSelectMode ? "Done" : "Select") {
                    viewModel.toggleTravellerMultiSelect()
                }
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(Color.ftdAccentOrange)
                .buttonStyle(.plain)
            }

            FTDTextField(
                label: "",
                placeholder: "Search by name or passport",
                text: $viewModel.travellerSearchQuery,
                autocapitalization: .never
            )

            ForEach(viewModel.filteredTravellerList) { item in
                travellerCard(item)
            }

            if viewModel.filteredTravellerList.isEmpty && !viewModel.travellerSearchQuery.isEmpty {
                Text("No travellers match your search.")
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, DesignTokens.Spacing.md)
            }

        }
    }

    private func travellerCard(_ item: TravellerListItem) -> some View {
        let isSelected = viewModel.selectedTravellerIds.contains(item.id)
        return VStack(alignment: .leading, spacing: 0) {
            // ─── Header row ───
            HStack(alignment: .center, spacing: 0) {
                if viewModel.isTravellerMultiSelectMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18))
                        .foregroundStyle(isSelected ? Color.ftdAccentOrange : Color.ftdTextSecondary)
                        .padding(.trailing, DesignTokens.Spacing.sm)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.fullName.isEmpty ? "—" : item.fullName)
                        .font(.ftdLabelMD)
                        .foregroundStyle(Color.ftdTextPrimary)
                        .lineLimit(1)
                    if !item.passportNo.isEmpty {
                        Text("Passport: \(item.passportNo)")
                            .font(.ftdLabelXS)
                            .foregroundStyle(Color.ftdAccentTeal)
                            .lineLimit(1)
                    }
                }
                Spacer()
                if !item.paxType.isEmpty {
                    Text(item.paxType.uppercased())
                        .font(.system(size: 9, weight: .bold))
                        .tracking(0.5)
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, 4)
                        .background(Color.ftdAccentOrange.opacity(0.10))
                        .foregroundStyle(Color.ftdAccentOrange)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.ftdAccentOrangeAlpha, lineWidth: 1))
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.top, DesignTokens.Spacing.sm)

            // ─── Detail grid ───
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.xxs) {
                    profileDetailColumn(label: "Title",      value: item.title)
                    profileDetailColumn(label: "First Name", value: item.firstName)
                    profileDetailColumn(label: "Last Name",  value: item.lastName)
                }
                HStack(alignment: .top, spacing: DesignTokens.Spacing.xxs) {
                    profileDetailColumn(label: "DOB",         value: item.dob)
                    profileDetailColumn(label: "Nationality", value: item.nationality)
                    profileDetailColumn(label: "Gender",      value: item.gender)
                }
                HStack(alignment: .top, spacing: DesignTokens.Spacing.xxs) {
                    profileDetailColumn(label: "Issue Country", value: item.issueCountry)
                    profileDetailColumn(label: "Expiry Date",   value: item.expiryDate)
                    profileDetailColumn(label: "Age",           value: item.age.isEmpty ? "—" : item.age)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.md)

            // ─── Actions ───
            if !viewModel.isTravellerMultiSelectMode {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    iconActionButton(systemName: "pencil") { viewModel.editTraveller(item) }
                    iconActionButton(systemName: "trash") {
                        Task { await viewModel.deleteTraveller(item) }
                    }
                    Spacer()
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.bottom, DesignTokens.Spacing.sm)
            }
        }
        .background(isSelected ? Color.ftdAccentOrange.opacity(0.05) : Color.ftdSurfaceSubtle)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .stroke(isSelected ? Color.ftdAccentOrangeAlpha : Color.ftdBorder, lineWidth: 1)
        )
        .opacity(viewModel.isDeletingTravellerId == item.id ? 0.5 : 1)
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.isTravellerMultiSelectMode {
                viewModel.toggleTravellerSelection(id: item.id)
            }
        }
    }

    private func profileDetailColumn(label: String, value: String, valueColor: Color = .ftdTextPrimary) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            Text(label)
                .font(.ftdLabelXS)
                .foregroundStyle(Color.ftdTextTertiary)
            Text(value.isEmpty ? "—" : value)
                .font(.ftdLabelMD)
                .foregroundStyle(value.isEmpty ? Color.ftdTextSecondary.opacity(0.5) : valueColor)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - GST Tab

    private var gstTab: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            // Collapsible Add / Edit GST form
            VStack(alignment: .leading, spacing: 0) {
                // Header row — always visible, tap to expand/collapse
                Button {
                    withAnimation(.easeInOut(duration: DesignTokens.Animation.standard)) {
                        if isGSTFormExpanded {
                            isGSTFormExpanded = false
                            viewModel.cancelGSTEdit()
                        } else {
                            isGSTFormExpanded = true
                        }
                    }
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("GST Details")
                                .font(.headline).fontWeight(.bold)
                                .foregroundStyle(Color.ftdTextPrimary)
                            if !isGSTFormExpanded {
                                Text(viewModel.editingGSTId == nil ? "Tap to add GST" : "Tap to edit GST")
                                    .font(.caption)
                                    .foregroundStyle(Color.ftdTextSecondary)
                            }
                        }
                        Spacer()
                        if !isGSTFormExpanded {
                            Label("Add GST", systemImage: "plus.circle.fill")
                                .font(.subheadline).fontWeight(.semibold)
                                .foregroundStyle(Color.ftdAccentOrange)
                                .labelStyle(.titleAndIcon)
                        } else {
                            Image(systemName: "chevron.up")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.ftdTextSecondary)
                        }
                    }
                    .padding(DesignTokens.Spacing.lg)
                }
                .buttonStyle(.plain)

                // Expandable form body
                if isGSTFormExpanded {
                    Divider().padding(.horizontal, DesignTokens.Spacing.lg)

                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                        if viewModel.editingGSTId != nil {
                            subsectionLabel("Edit GST Details")
                        }

                        FTDTextField(
                            label: "GSTIN*",
                            placeholder: "GSTIN*",
                            text: $viewModel.gstNumber,
                            autocapitalization: .characters
                        )
                        FTDTextField(label: "Company Name*", placeholder: "Company Name*", text: $viewModel.gstCompany)
                        FTDTextField(
                            label: "Contact Number*",
                            placeholder: "Contact Number*",
                            text: $viewModel.gstMobile,
                            keyboardType: .phonePad
                        )
                        FTDTextField(
                            label: "Email Address*",
                            placeholder: "Email Address*",
                            text: $viewModel.gstEmail,
                            keyboardType: .emailAddress,
                            autocapitalization: .never
                        )
                        FTDTextField(label: "Address*", placeholder: "Address*", text: $viewModel.gstAddress, autocapitalization: .sentences)

                        if let msg = viewModel.gstFormMessage {
                            statusMessage(msg, isError: viewModel.gstFormMessageIsError)
                        }

                        FTDPrimaryButton(
                            title: viewModel.editingGSTId == nil ? "ADD GST" : "UPDATE GST",
                            isLoading: viewModel.isSubmittingGST
                        ) {
                            Task {
                                await viewModel.submitGST()
                                if !viewModel.gstFormMessageIsError {
                                    withAnimation(.easeInOut(duration: DesignTokens.Animation.standard)) {
                                        isGSTFormExpanded = false
                                    }
                                }
                            }
                        }

                        if viewModel.editingGSTId != nil {
                            Button {
                                withAnimation(.easeInOut(duration: DesignTokens.Animation.standard)) {
                                    viewModel.cancelGSTEdit()
                                    isGSTFormExpanded = false
                                }
                            } label: {
                                Text("CANCEL")
                                    .font(.subheadline).fontWeight(.semibold)
                                    .foregroundStyle(Color.ftdAccentTeal)
                                    .frame(maxWidth: .infinity, minHeight: 44)
                                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: DesignTokens.Radius.button)
                                            .stroke(Color.ftdAccentTeal, lineWidth: 1.5)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(DesignTokens.Spacing.lg)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .background(Color.ftdCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
            .onChange(of: viewModel.editingGSTId) { _, newId in
                if newId != nil {
                    withAnimation(.easeInOut(duration: DesignTokens.Animation.standard)) {
                        isGSTFormExpanded = true
                    }
                }
            }

            // GST List
            if !viewModel.gstList.isEmpty {
                gstListSection
            }
        }
    }

    // MARK: - GST List

    private var gstListSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack {
                Text("Your GST List")
                    .font(.headline).fontWeight(.bold)
                    .foregroundStyle(Color.ftdTextPrimary)
                Spacer()
                Button(viewModel.isGSTMultiSelectMode ? "Done" : "Select") {
                    viewModel.toggleGSTMultiSelect()
                }
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(Color.ftdAccentOrange)
                .buttonStyle(.plain)
            }

            FTDTextField(
                label: "",
                placeholder: "Search GST",
                text: $viewModel.gstSearchQuery,
                autocapitalization: .never
            )

            ForEach(viewModel.filteredGSTList) { item in
                gstCard(item)
            }

            if viewModel.filteredGSTList.isEmpty && !viewModel.gstSearchQuery.isEmpty {
                Text("No GST records match your search.")
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, DesignTokens.Spacing.md)
            }

        }
    }

    private func gstCard(_ item: GSTListItem) -> some View {
        let isSelected = viewModel.selectedGSTIds.contains(item.id)
        return VStack(alignment: .leading, spacing: 0) {
            // ─── Header row ───
            HStack(alignment: .center, spacing: 0) {
                if viewModel.isGSTMultiSelectMode {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 18))
                        .foregroundStyle(isSelected ? Color.ftdAccentOrange : Color.ftdTextSecondary)
                        .padding(.trailing, DesignTokens.Spacing.sm)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(item.company.isEmpty ? "—" : item.company)
                        .font(.ftdLabelMD)
                        .foregroundStyle(Color.ftdTextPrimary)
                        .lineLimit(1)
                    Text(item.gstin.isEmpty ? "—" : item.gstin)
                        .font(.ftdLabelXS)
                        .foregroundStyle(Color.ftdTextTertiary)
                        .lineLimit(1)
                }
                Spacer()
                Text("GST")
                    .font(.system(size: 9, weight: .bold))
                    .tracking(0.5)
                    .padding(.horizontal, DesignTokens.Spacing.sm)
                    .padding(.vertical, 4)
                    .background(Color.ftdAccentOrange.opacity(0.10))
                    .foregroundStyle(Color.ftdAccentOrange)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.ftdAccentOrangeAlpha, lineWidth: 1))
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.top, DesignTokens.Spacing.sm)

            // ─── Detail grid ───
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.xxs) {
                    profileDetailColumn(label: "Contact Number", value: item.mobileNo, valueColor: .ftdAccentTeal)
                    profileDetailColumn(label: "Email Address",  value: item.email)
                }
                profileDetailColumn(label: "Address", value: item.address)
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.md)

            // ─── Actions ───
            if !viewModel.isGSTMultiSelectMode {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    iconActionButton(systemName: "pencil") { viewModel.editGST(item) }
                    iconActionButton(systemName: "trash") {
                        Task { await viewModel.deleteGST(item) }
                    }
                    Spacer()
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.bottom, DesignTokens.Spacing.sm)
            }
        }
        .background(isSelected ? Color.ftdAccentOrange.opacity(0.05) : Color.ftdSurfaceSubtle)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .stroke(isSelected ? Color.ftdAccentOrangeAlpha : Color.ftdBorder, lineWidth: 1)
        )
        .opacity(viewModel.isDeletingGSTId == item.id ? 0.5 : 1)
        .contentShape(Rectangle())
        .onTapGesture {
            if viewModel.isGSTMultiSelectMode {
                viewModel.toggleGSTSelection(id: item.id)
            }
        }
    }

    private func iconActionButton(systemName: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(Color.ftdAccentOrange)
                .frame(width: 34, height: 34)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.ftdAccentOrange, lineWidth: 1.2)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Shared Helpers

    @ViewBuilder
    private func formCard(@ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignTokens.Spacing.lg)
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.headline).fontWeight(.bold)
            .foregroundStyle(Color.ftdTextPrimary)
    }

    private func subsectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.subheadline).fontWeight(.semibold)
            .foregroundStyle(Color.ftdTextSecondary)
    }

    private func readOnlyField(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
            ftdRequiredLabel(label).font(.caption)
            Text(value)
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, DesignTokens.Spacing.inputHorizontal)
        .frame(minHeight: DesignTokens.Spacing.inputFieldHeight, alignment: .leading)
        .background(Color.ftdInputBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                .stroke(Color.ftdBorder, lineWidth: 1)
        )
    }

    @ViewBuilder
    private var floatingMultiDeleteBar: some View {
        if viewModel.selectedTab == .traveller && viewModel.isTravellerMultiSelectMode {
            VStack(spacing: 0) {
                Divider()
                FTDPrimaryButton(
                    title: viewModel.selectedTravellerIds.isEmpty
                        ? "SELECT TRAVELLERS TO DELETE"
                        : "DELETE SELECTED (\(viewModel.selectedTravellerIds.count))",
                    isLoading: viewModel.isDeletingMultipleTravellers
                ) {
                    guard !viewModel.selectedTravellerIds.isEmpty else { return }
                    Task { await viewModel.deleteSelectedTravellers() }
                }
                .disabled(viewModel.selectedTravellerIds.isEmpty)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.md)
            }
            .background(Color.ftdCardBackground)
            .shadow(color: .black.opacity(0.08), radius: 8, y: -4)
        } else if viewModel.selectedTab == .gst && viewModel.isGSTMultiSelectMode {
            VStack(spacing: 0) {
                Divider()
                FTDPrimaryButton(
                    title: viewModel.selectedGSTIds.isEmpty
                        ? "SELECT GST TO DELETE"
                        : "DELETE SELECTED (\(viewModel.selectedGSTIds.count))",
                    isLoading: viewModel.isDeletingMultipleGSTs
                ) {
                    guard !viewModel.selectedGSTIds.isEmpty else { return }
                    Task { await viewModel.deleteSelectedGSTs() }
                }
                .disabled(viewModel.selectedGSTIds.isEmpty)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.md)
            }
            .background(Color.ftdCardBackground)
            .shadow(color: .black.opacity(0.08), radius: 8, y: -4)
        }
    }

    private var dobPickerSheet: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Text("Date of Birth")
                .font(.headline).fontWeight(.bold)
                .foregroundStyle(Color.ftdTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.lg)
            DatePicker("", selection: $viewModel.travellerDOBDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Color.ftdAccentOrange)
                .labelsHidden()
                .padding(.horizontal, DesignTokens.Spacing.lg)
            FTDPrimaryButton(title: "Done") { showTravellerDOBPicker = false }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.lg)
        }
        .presentationDetents([.large])
        .background(Color.ftdCardBackground)
    }

    private var expiryPickerSheet: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Text("Expiry Date")
                .font(.headline).fontWeight(.bold)
                .foregroundStyle(Color.ftdTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.lg)
            DatePicker("", selection: $viewModel.travellerExpiryDateObj, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Color.ftdAccentOrange)
                .labelsHidden()
                .padding(.horizontal, DesignTokens.Spacing.lg)
            FTDPrimaryButton(title: "Done") { showTravellerExpiryPicker = false }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.lg)
        }
        .presentationDetents([.large])
        .background(Color.ftdCardBackground)
    }

    private func statusMessage(_ text: String, isError: Bool) -> some View {
        Text(text)
            .font(.caption).fontWeight(.medium)
            .foregroundStyle(isError ? Color.ftdDestructiveRed : Color.ftdAccentTeal)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
    }

    private var agencyLogoSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Agency Logo")
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextPrimary)

            HStack(spacing: DesignTokens.Spacing.md) {
                // Thumbnail — picked image takes priority over remote URL
                logoThumbnail
                    .frame(width: 80, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))

                PhotosPicker(
                    selection: $selectedLogoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text("Choose File")
                        .font(.subheadline)
                        .foregroundStyle(Color.ftdTextPrimary)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .padding(.vertical, DesignTokens.Spacing.sm)
                        .background(Color.ftdInputBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                                .stroke(Color.ftdBorder, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)

                Text(selectedLogoFileName ?? "no file\nselected")
                    .font(.caption)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .lineLimit(2)
            }

            Text("Allowed formats: JPG, JPEG, PNG.\nRecommended size: 120 × 80 px.")
                .font(.caption2)
                .foregroundStyle(Color.ftdTextSecondary)
        }
        .onChange(of: selectedLogoItem) { _, newItem in
            Task {
                guard let newItem else { return }
                // Load raw data for upload
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    viewModel.selectedLogoData = data
                    if let uiImage = UIImage(data: data) {
                        selectedLogoImage = Image(uiImage: uiImage)
                    }
                }
                selectedLogoFileName = newItem.itemIdentifier.flatMap { _ in "image selected" } ?? "image selected"
            }
        }
    }

    // MARK: - Certificate Preview Sheet

    private var certificateDocumentView: AgentCertificateDocumentView {
        let fullAddress = [viewModel.address, viewModel.city, viewModel.state, viewModel.pinCode, viewModel.country]
            .filter { !$0.isEmpty }.joined(separator: ", ")
        return AgentCertificateDocumentView(
            agentNo: viewModel.agentNo,
            agencyName: viewModel.agencyName,
            address: fullAddress,
            memberSince: viewModel.memberSince,
            images: certImages
        )
    }

    private var certificatePreviewSheet: some View {
        NavigationStack {
            ScrollView {
                let scale = min(
                    UIScreen.main.bounds.height * 0.70 / 842,
                    (UIScreen.main.bounds.width - 32) / 595
                )
                certificateDocumentView
                    .frame(width: 595, height: 842)
                    .scaleEffect(scale)
                    .frame(width: 595 * scale, height: 842 * scale)
                    .padding(.horizontal, 16)
                    .padding(.vertical, DesignTokens.Spacing.lg)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Certificate Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { showCertificatePreview = false }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        Task {
                            isGeneratingCertificate = true
                            if certImages.logo == nil {
                                certImages = await CertificateImages.fetch()
                            }
                            if let url = generateCertificatePDF() {
                                certificateURL = url
                            }
                            isGeneratingCertificate = false
                            if certificateURL != nil {
                                showCertificatePreview = false
                                try? await Task.sleep(nanoseconds: 350_000_000)
                                if let url = certificateURL {
                                    let ac = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                                    if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                       let root = scene.windows.first?.rootViewController {
                                        root.present(ac, animated: true)
                                    }
                                }
                            }
                        }
                    } label: {
                        if isGeneratingCertificate {
                            ProgressView().tint(Color.ftdAccentOrange)
                        } else {
                            Label("Download PDF", systemImage: "arrow.down.circle.fill")
                                .foregroundStyle(Color.ftdAccentOrange)
                        }
                    }
                    .disabled(isGeneratingCertificate)
                }
            }
        }
        .task { certImages = await CertificateImages.fetch() }
    }

    // MARK: - Certificate PDF Generation

    @MainActor
    private func generateCertificatePDF() -> URL? {
        let renderer = ImageRenderer(content: certificateDocumentView)
        renderer.proposedSize = .init(width: 595, height: 842)

        let filename = "FTD Travel_Certificate_\(viewModel.agentNo.isEmpty ? "agent" : viewModel.agentNo).pdf"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)

        renderer.render { size, draw in
            var box = CGRect(origin: .zero, size: size)
            guard let context = CGContext(url as CFURL, mediaBox: &box, nil) else { return }
            context.beginPDFPage(nil)
            draw(context)
            context.endPDFPage()
            context.closePDF()
        }
        return url
    }

    @ViewBuilder
    private var logoThumbnail: some View {
        if let picked = selectedLogoImage {
            picked.resizable().scaledToFill()
        } else if let url = viewModel.agentLogoURL {
            FTDRemoteImage(url: url, contentMode: .fill) {
                FTDRemoteImage(url: FTDImageURL.agentLogoDefault, contentMode: .fill)
            }
            .scaledToFill()
        } else {
            FTDRemoteImage(url: FTDImageURL.agentLogoDefault, contentMode: .fill)
                .scaledToFill()
        }
    }
}

// MARK: - Share Sheet

private struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
