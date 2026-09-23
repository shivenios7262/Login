import SwiftUI

struct GroupFareView: View {
    @Bindable var viewModel: GroupFareViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isFormExpanded        = true
    @State private var isTermsExpanded       = false
    @State private var showDepartureDatePicker = false
    @State private var showReturnDatePicker    = false

    private static let groupFareDateFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd-MMM-yyyy"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ftdInputBackground.ignoresSafeArea()
                if viewModel.isSubmitted {
                    successView
                } else {
                    formContent
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.ftdCardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Group Fare")
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
                get: { viewModel.alertMessage != nil },
                set: { if !$0 { viewModel.alertMessage = nil } }
            )) {
                Button(String(localized: "OK")) { viewModel.alertMessage = nil }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
            .sheet(isPresented: $showDepartureDatePicker) {
                groupFareDatePickerSheet(
                    title: "Departure Date",
                    date: Binding(
                        get: { Self.groupFareDateFmt.date(from: viewModel.departureDate) ?? viewModel.minDepartureDate },
                        set: {
                            viewModel.departureDate = Self.groupFareDateFmt.string(from: $0)
                            viewModel.fieldErrors.removeValue(forKey: "departureDate")
                        }
                    ),
                    minDate: viewModel.minDepartureDate
                ) { showDepartureDatePicker = false }
            }
            .sheet(isPresented: $showReturnDatePicker) {
                groupFareDatePickerSheet(
                    title: "Return Date",
                    date: Binding(
                        get: {
                            Self.groupFareDateFmt.date(from: viewModel.returnDate)
                                ?? Self.groupFareDateFmt.date(from: viewModel.departureDate)
                                ?? viewModel.minDepartureDate
                        },
                        set: {
                            viewModel.returnDate = Self.groupFareDateFmt.string(from: $0)
                            viewModel.fieldErrors.removeValue(forKey: "returnDate")
                        }
                    ),
                    minDate: Self.groupFareDateFmt.date(from: viewModel.departureDate) ?? viewModel.minDepartureDate
                ) { showReturnDatePicker = false }
            }
        }
        .task {
            viewModel.reset()
            await viewModel.loadAirports()
        }
    }

    // MARK: - Form Content

    private var formContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                heroBanner
                formCard
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.top, DesignTokens.Spacing.lg)
                termsCard
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.top, DesignTokens.Spacing.md)
                    .padding(.bottom, DesignTokens.Spacing.xxxl)
            }
        }
        .overlay {
            if viewModel.isSubmitting { loadingOverlay }
        }
    }

    // MARK: - Hero Banner

    private var heroBanner: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text(String(localized: "Group Fare"))
                .font(.title2).fontWeight(.bold)
                .foregroundStyle(.white)
            HStack(spacing: DesignTokens.Spacing.xs) {
                Text(String(localized: "Home"))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.70))
                Text("/")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.45))
                Text(String(localized: "Group Fare"))
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(Color.ftdAccentOrange)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.bottom, DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity, minHeight: 160, maxHeight: 160, alignment: .bottomLeading)
        .background(
            FTDRemoteImage(
                url: FTDImageURL.groupFareBanner,
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

    // MARK: - Form Card

    private var formCard: some View {
        VStack(spacing: 0) {
            collapsibleHeader(
                isExpanded: $isFormExpanded,
                title: "Get the best ",
                highlight: "Group Fare",
                trailing: " quote from FTD Travel!"
            )

            if isFormExpanded {
                Divider().overlay(Color.ftdBorder)

                VStack(spacing: DesignTokens.Spacing.md) {
                    // Row 1: Agent Email | Agent ID
                    HStack(spacing: DesignTokens.Spacing.md) {
                        readOnlyField(label: "Agent Email", value: viewModel.agentEmail, placeholder: "support@ftd.tra")
                        readOnlyField(label: "Agent ID", value: viewModel.agentID, placeholder: "SMSA1B011111")
                    }

                    // Row 2: Mobile | Purpose
                    HStack(spacing: DesignTokens.Spacing.md) {
                        readOnlyField(label: "Mobile Number", value: viewModel.mobileNumber, placeholder: "Mobile")
                        FTDDropdownField(
                            label: "Purpose",
                            placeholder: "Select purpose",
                            selection: $viewModel.purpose,
                            options: GroupFarePurpose.allCases,
                            optionLabel: { $0.rawValue }
                        )
                    }

                    // Row 3: Journey (full width)
                    FTDDropdownField(
                        label: "Journey",
                        placeholder: "Choose your Journey",
                        selection: $viewModel.journey,
                        options: GroupFareJourney.allCases,
                        optionLabel: { $0.rawValue }
                    )
                    .onChange(of: viewModel.journey) { _, _ in
                        viewModel.clearReturnErrors()
                    }

                    // Row 4: From City / To City (full width, stacked)
                    VStack(spacing: DesignTokens.Spacing.md) {
                        AirportSearchField(
                            label: "From City",
                            placeholder: "Search city",
                            selection: $viewModel.fromAirport,
                            airports: viewModel.airports,
                            errorMessage: viewModel.fieldErrors["fromAirport"]
                        )
                        AirportSearchField(
                            label: "To City",
                            placeholder: "Search city",
                            selection: $viewModel.toAirport,
                            airports: viewModel.airports,
                            errorMessage: viewModel.fieldErrors["toAirport"]
                        )
                    }
                    .zIndex(1)

                    // Row 5: Departure Date | Return Date (hidden for One Way)
                    if viewModel.isRoundTrip {
                        HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                            datePickerButton(
                                label: "Departure Date",
                                value: viewModel.departureDate,
                                placeholder: "Select date",
                                isPlaceholder: viewModel.departureDate.isEmpty,
                                errorMessage: viewModel.fieldErrors["departureDate"]
                            ) { showDepartureDatePicker = true }
                            datePickerButton(
                                label: "Return Date",
                                value: viewModel.returnDate,
                                placeholder: "Select date",
                                isPlaceholder: viewModel.returnDate.isEmpty,
                                errorMessage: viewModel.fieldErrors["returnDate"]
                            ) { showReturnDatePicker = true }
                        }
                    } else {
                        datePickerButton(
                            label: "Departure Date",
                            value: viewModel.departureDate,
                            placeholder: "Select date",
                            isPlaceholder: viewModel.departureDate.isEmpty,
                            errorMessage: viewModel.fieldErrors["departureDate"]
                        ) { showDepartureDatePicker = true }
                    }

                    // Row 6: No. of Adult | No. of Children
                    HStack(spacing: DesignTokens.Spacing.md) {
                        FTDTextField(
                            label: "No. of Adult",
                            placeholder: "Min. 15",
                            text: $viewModel.noOfAdult,
                            errorMessage: viewModel.fieldErrors["noOfAdult"],
                            keyboardType: .numberPad
                        )
                        FTDTextField(
                            label: "No. of Children",
                            placeholder: "0",
                            text: $viewModel.noOfChildren,
                            keyboardType: .numberPad
                        )
                    }

                    // Row 7: No. of Infants | Expected Fare per pax
                    HStack(spacing: DesignTokens.Spacing.md) {
                        FTDTextField(
                            label: "No. of Infants",
                            placeholder: "0",
                            text: $viewModel.noOfInfants,
                            keyboardType: .numberPad
                        )
                        FTDTextField(
                            label: "Expected Fare/pax",
                            placeholder: "₹2,000",
                            text: $viewModel.expectedFare,
                            errorMessage: viewModel.fieldErrors["expectedFare"],
                            keyboardType: .numberPad
                        )
                    }

                    // Row 8: Onward Flight | Return Flight (hidden for One Way)
                    if viewModel.isRoundTrip {
                        HStack(spacing: DesignTokens.Spacing.md) {
                            FTDTextField(
                                label: "Onward Flight Details",
                                placeholder: "Airline & flight no.",
                                text: $viewModel.onwardFlightDetails,
                                errorMessage: viewModel.fieldErrors["onwardFlightDetails"]
                            )
                            FTDTextField(
                                label: "Return Flight Details",
                                placeholder: "Airline & flight no.",
                                text: $viewModel.returnFlightDetails,
                                errorMessage: viewModel.fieldErrors["returnFlightDetails"]
                            )
                        }
                    } else {
                        FTDTextField(
                            label: "Onward Flight Details",
                            placeholder: "Airline & flight no.",
                            text: $viewModel.onwardFlightDetails,
                            errorMessage: viewModel.fieldErrors["onwardFlightDetails"]
                        )
                    }

                    // Row 9: Remark (full width, multiline)
                    remarkField

                    nextStepsSection

                    FTDPrimaryButton(
                        title: String(localized: "Submit"),
                        isLoading: viewModel.isSubmitting
                    ) {
                        Task { await viewModel.submit() }
                    }
                }
                .padding(DesignTokens.Spacing.lg)
                .onChange(of: viewModel.fromAirport) { _, newValue in
                    if newValue != .empty { viewModel.fieldErrors.removeValue(forKey: "fromAirport") }
                }
                .onChange(of: viewModel.toAirport) { _, newValue in
                    if newValue != .empty { viewModel.fieldErrors.removeValue(forKey: "toAirport") }
                }
                .onChange(of: viewModel.noOfAdult) { _, _ in
                    viewModel.fieldErrors.removeValue(forKey: "noOfAdult")
                }
                .onChange(of: viewModel.expectedFare) { _, _ in
                    viewModel.fieldErrors.removeValue(forKey: "expectedFare")
                }
                .onChange(of: viewModel.onwardFlightDetails) { _, _ in
                    viewModel.fieldErrors.removeValue(forKey: "onwardFlightDetails")
                }
                .onChange(of: viewModel.returnFlightDetails) { _, _ in
                    viewModel.fieldErrors.removeValue(forKey: "returnFlightDetails")
                }
                .onChange(of: viewModel.remark) { _, _ in
                    viewModel.fieldErrors.removeValue(forKey: "remark")
                }
            }
        }
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .shadow(color: .black.opacity(0.07), radius: 8, y: 3)
    }

    // MARK: - Collapsible Section Header

    private func collapsibleHeader(
        isExpanded: Binding<Bool>,
        title: String,
        highlight: String? = nil,
        trailing: String = ""
    ) -> some View {
        Button {
            withAnimation(.easeInOut(duration: DesignTokens.Animation.standard)) {
                isExpanded.wrappedValue.toggle()
            }
        } label: {
            HStack(spacing: DesignTokens.Spacing.sm) {
                if let hl = highlight {
                    (Text(title).foregroundStyle(Color.ftdTextPrimary)
                     + Text(hl).foregroundStyle(Color.ftdAccentOrange)
                     + Text(trailing).foregroundStyle(Color.ftdTextPrimary))
                    .font(.subheadline).fontWeight(.semibold)
                    .fixedSize(horizontal: false, vertical: true)
                } else {
                    Text(title)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(Color.ftdTextPrimary)
                }
                Spacer()
                Image(systemName: isExpanded.wrappedValue ? "chevron.up" : "chevron.down")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(Color.ftdTextSecondary)
            }
            .padding(DesignTokens.Spacing.lg)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Read-only Field

    private func readOnlyField(label: String, value: String, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
            Text(label)
                .font(.ftdPlaceholder)
                .foregroundStyle(Color.ftdTextTertiary)
            Text(value.isEmpty ? placeholder : value)
                .font(.ftdBodySM)
                .foregroundStyle(value.isEmpty ? Color.ftdTextSecondary : Color.ftdTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, DesignTokens.Spacing.inputHorizontal)
        .padding(.top, DesignTokens.Spacing.inputVertical)
        .frame(maxWidth: .infinity, minHeight: DesignTokens.Spacing.inputFieldHeight, alignment: .topLeading)
        .background(Color.ftdInputBackground, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                .stroke(Color.ftdBorder, lineWidth: 1)
        )
    }

    // MARK: - Date Picker Field

    private func datePickerButton(
        label: String,
        value: String,
        placeholder: String,
        isPlaceholder: Bool,
        errorMessage: String?,
        action: @escaping () -> Void
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
            Text(label)
                .font(.ftdPlaceholder)
                .foregroundStyle(Color.ftdTextTertiary)
            Button(action: action) {
                HStack(spacing: 8) {
                    Image("cal")
                        .foregroundStyle(Color.ftdTextSecondary)
                    Text(isPlaceholder ? placeholder : value)
                        .font(.ftdBodySM)
                        .foregroundStyle(isPlaceholder ? Color.ftdTextTertiary : Color.ftdTextSecondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .stroke(errorMessage != nil ? Color.ftdDestructiveRed : Color.ftdBorder,
                                lineWidth: errorMessage != nil ? 1.5 : 1)
                )
            }
            .buttonStyle(.plain)

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.ftdDestructiveRed)
                    .padding(.horizontal, DesignTokens.Spacing.xxs)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func groupFareDatePickerSheet(
        title: String,
        date: Binding<Date>,
        minDate: Date? = nil,
        onDone: @escaping () -> Void
    ) -> some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Text(title)
                .font(.ftdSectionHeaderMedium)
                .foregroundStyle(Color.ftdTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.md)
            if let min = minDate {
                DatePicker("", selection: date, in: min..., displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Color.ftdAccentOrange)
                    .labelsHidden()
                    .padding(.horizontal, DesignTokens.Spacing.sm)
            } else {
                DatePicker("", selection: date, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .tint(Color.ftdAccentOrange)
                    .labelsHidden()
                    .padding(.horizontal, DesignTokens.Spacing.sm)
            }
            FTDPrimaryButton(title: "Done") { onDone() }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.md)
        }
        .presentationDetents([.height(520)])
        .presentationDragIndicator(.visible)
        .background(Color.ftdCardBackground)
    }

    // MARK: - Remark Field

    private var remarkField: some View {
        let hasError = viewModel.fieldErrors["remark"] != nil
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                Text(String(localized: "Remark"))
                    .font(.ftdPlaceholder)
                    .foregroundStyle(Color.ftdTextTertiary)
                TextField(String(localized: "Type here"), text: $viewModel.remark, axis: .vertical)
                    .font(.ftdBodySM)
                    .lineLimit(3...6)
                    .autocorrectionDisabled()
                    .frame(maxWidth: .infinity)
            }
            .padding(.horizontal, DesignTokens.Spacing.inputHorizontal)
            .padding(.vertical, DesignTokens.Spacing.inputVertical)
            .background(Color.ftdCardBackground, in: RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                    .stroke(hasError ? Color.ftdDestructiveRed : Color.ftdBorder,
                            lineWidth: hasError ? 1.5 : 1)
            )

            if let error = viewModel.fieldErrors["remark"] {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(Color.ftdDestructiveRed)
                    .padding(.horizontal, DesignTokens.Spacing.xxs)
            }
        }
    }

    // MARK: - Next Steps

    private var nextStepsSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Next Steps:"))
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextPrimary)

            bulletRow(text: "We are getting the best quotes from Airlines - Kindly sit tight...")
            HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                Circle()
                    .fill(Color.ftdTextSecondary.opacity(0.40))
                    .frame(width: 5, height: 5)
                    .padding(.top, 6)
                (Text(String(localized: "For more details, call us @ "))
                 + Text("73533 11550")
                     .foregroundStyle(Color.ftdAccentOrange).bold())
                    .font(.footnote)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            bulletRow(text: "Working Hours: Mon - Sat (11AM to 7PM)")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func bulletRow(text: String) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Circle()
                .fill(Color.ftdTextSecondary.opacity(0.40))
                .frame(width: 5, height: 5)
                .padding(.top, 6)
            Text(text)
                .font(.footnote)
                .foregroundStyle(Color.ftdTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    // MARK: - Terms Card

    private var termsCard: some View {
        VStack(spacing: 0) {
            collapsibleHeader(isExpanded: $isTermsExpanded, title: "Important Terms & Condition")

            if isTermsExpanded {
                Divider().overlay(Color.ftdBorder)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    ForEach(Self.termsItems, id: \.self) { term in
                        bulletRow(text: term)
                    }
                }
                .padding(DesignTokens.Spacing.lg)
            }
        }
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .shadow(color: .black.opacity(0.07), radius: 8, y: 3)
    }

    // MARK: - Success View

    private var successView: some View {
        VStack(spacing: DesignTokens.Spacing.xxl) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.ftdAccentTeal.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.ftdAccentTeal)
            }
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text(String(localized: "Request Submitted!"))
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(Color.ftdTextPrimary)
                if let refNo = viewModel.submittedReferenceNo {
                    Text(refNo)
                        .font(.subheadline).fontWeight(.semibold)
                        .foregroundStyle(Color.ftdAccentOrange)
                        .padding(.vertical, DesignTokens.Spacing.xs)
                }
                Text(String(localized: "Our team is getting the best group fare quotes. We'll reach out to you shortly."))
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.Spacing.xxl)
            }
            Spacer()
            FTDPrimaryButton(title: String(localized: "Done")) { dismiss() }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.xxxl)
        }
    }

    // MARK: - Loading Overlay

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: DesignTokens.Spacing.lg) {
                ProgressView()
                    .tint(Color.ftdAccentOrange)
                    .scaleEffect(1.5)
                Text(String(localized: "Submitting..."))
                    .font(.subheadline)
                    .foregroundStyle(.white)
            }
            .padding(DesignTokens.Spacing.xxl)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.cardLg))
        }
    }

    // MARK: - Terms Content

    private static let termsItems: [String] = [
        "Group Fares are provided by Airlines and hence takes few hours to get one",
        "Most of the airlines group desk does not work during weekend / national holiday",
        "Fares are available on Immediate Closure Basis - subject to confirmation from airline head office and seat availability at the time of confirmation",
        "Payment Terms – 100% Advance & Non Commissionable / Non Deposit Incentive / Non Turn Over Incentive etc",
        "If GST Invoice is required, GSTIN has to be provided before booking",
        "For certain airlines Group PNR is generated after 1 or 2 working days from payment confirmation",
        "Passenger name should be given as per Passport / ID Proof & Group Leader Direct Contact Number is compulsory while providing Name List",
        "ADM, if raised for any reason by the Airlines, will be charged to the Agency Account",
        "We are not liable for Visa/Immigration, Vaccination, any Travel Documents, OK to BOARD etc would be your responsibility, should it be a requirement",
        "Please ensure in case of any discrepancy to revert us immediately (within 2 hours), else it will be considered in line with the requirements and any change will be done as per current flight condition with applicable charge. By completing and submitting this form you agree to the terms and conditions. Detailed terms & conditions: https://www.ftd.travel/terms-of-use/"
    ]
}
