import SwiftUI

// MARK: - Preference Key

private struct BookingsHeroCollapsedKey: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) { value = nextValue() }
}

// MARK: - MyBookingsView

struct MyBookingsView: View {
    @Bindable var viewModel: BookingsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isFilterSheetPresented = false
    @FocusState private var isSearchFocused: Bool
    @State private var isHeroCollapsed = false
    @State private var scrollToTop = false
    @State private var searchQuery = ""
    @State private var currentPage = 1
    @State private var alertBooking: AgentFlightBooking? = nil
    @State private var showDatePicker = false
    @State private var pickerDate = Date()
    @State private var pickerLabel = ""
    @State private var onDatePicked: ((String) -> Void)? = nil

    private let heroHeight: CGFloat = 160
    private let pageSize = 10

    private static let apiFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    var body: some View {
        ZStack(alignment: .top) {
            Color.ftdInputBackground.ignoresSafeArea()

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        Color.clear.frame(height: 0).id("bookingsTop")
                        parallaxHero

                        Section {
                            contentArea
                                .background(Color.ftdInputBackground)
                                .animation(.easeInOut(duration: 0.35), value: viewModel.isLoading)
                                .animation(.easeInOut(duration: 0.35), value: viewModel.flightBookings.count)
                        } header: {
                            VStack(spacing: 0) {
                                customTabBar
                                Divider()
                                controlsRow
                                    .padding(.horizontal, DesignTokens.Spacing.md)
                                    .padding(.vertical, DesignTokens.Spacing.sm)
                                Divider()
                                activeFilterChipsRow
                                if !activeFilterChipsData.isEmpty { Divider() }
                            }
                            .background(
                                GeometryReader { geo in
                                    let headerY = geo.frame(in: .named("bookingsScroll")).minY
                                    Color.ftdCardBackground
                                        .ignoresSafeArea(edges: .top)
                                        .preference(key: BookingsHeroCollapsedKey.self, value: headerY < heroHeight * 0.4)
                                }
                            )
                            .animation(.easeInOut(duration: 0.2), value: isHeroCollapsed)
                            .zIndex(1)
                        }
                    }
                }
                .coordinateSpace(name: "bookingsScroll")
                .onPreferenceChange(BookingsHeroCollapsedKey.self) { isHeroCollapsed = $0 }
                .onChange(of: scrollToTop) { _, _ in
                    withAnimation { proxy.scrollTo("bookingsTop", anchor: .top) }
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image("backImg")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.ftdTextPrimary)
                }
                .buttonStyle(.plain)

                Spacer()

                Text("My Bookings")
                    .font(.headline)
                    .foregroundStyle(Color.ftdTextPrimary)

                Spacer()

                Button { isFilterSheetPresented = true } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(activeFilterCount > 0 ? Color.ftdAccentOrange : Color.ftdTextSecondary)
                        if activeFilterCount > 0 {
                            Text("\(activeFilterCount)")
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 14, height: 14)
                                .background(Color.ftdAccentOrange)
                                .clipShape(Circle())
                                .offset(x: 5, y: -5)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(Color.ftdCardBackground.ignoresSafeArea(edges: .top))
        }
        .task { await viewModel.fetchBookings() }
        .onChange(of: viewModel.selectedTab) { _, _ in
            searchQuery = ""
            currentPage = 1
            scrollToTop.toggle()
            Task { await viewModel.search() }
        }
        .onChange(of: searchQuery) { _, _ in
            currentPage = 1
        }
        .sheet(isPresented: $isFilterSheetPresented) { filterSheet }
    }

    // MARK: - Parallax Hero

    private var parallaxHero: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .named("bookingsScroll")).minY
            let isOverscrolling = minY > 0
            FTDRemoteImage(url: FTDImageURL.myBookingsBanner, contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: isOverscrolling ? heroHeight + minY : heroHeight)
                .offset(y: isOverscrolling ? -minY : minY * 0.4)
                .clipped()
        }
        .frame(height: heroHeight)
    }

    // MARK: - Tab Bar (chip style)

    private var customTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(BookingTab.allCases) { tab in
                    let isSelected = viewModel.selectedTab == tab
                    Button {
                        withAnimation(.easeInOut(duration: DesignTokens.Animation.fast)) {
                            viewModel.selectedTab = tab
                        }
                    } label: {
                        Text(tab.rawValue)
                            .font(.ftdLabelMD)
                            .foregroundStyle(isSelected ? Color.ftdAccentOrange : Color.ftdTextSecondary)
                            .padding(.horizontal, DesignTokens.Spacing.md)
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
        }
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.button)
                .stroke(Color.ftdAccentOrangeAlpha, lineWidth: 1)
        )
        .overlay(alignment: .trailing) {
            LinearGradient(
                colors: [Color.ftdCardBackground.opacity(0), Color.ftdCardBackground],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 32)
            .allowsHitTesting(false)
        }
        .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: viewModel.selectedTab)
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    // MARK: - Controls Row

    private var controlsRow: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.caption)
                    .foregroundStyle(isSearchFocused ? Color.ftdAccentOrange : Color.ftdTextSecondary)
                TextField("Search bookings", text: $searchQuery)
                    .font(.ftdBodySM)
                    .autocorrectionDisabled()
                    .focused($isSearchFocused)
                    .onSubmit {
                        isSearchFocused = false
                    }
                if !searchQuery.isEmpty {
                    Button { searchQuery = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.ftdTextSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                    .stroke(isSearchFocused ? Color.ftdAccentOrange : Color.ftdBorder, lineWidth: 1)
            )
            .frame(maxWidth: .infinity)

            Button { isFilterSheetPresented = true } label: {
                HStack(spacing: isSearchFocused ? 0 : 4) {
                    Image(systemName: "line.3.horizontal.decrease")
                        .font(.caption)
                    if !isSearchFocused {
                        Text(activeFilterCount > 0 ? "Filters (\(activeFilterCount))" : "Filters")
                            .font(.ftdBodySM)
                            .fixedSize()
                            .transition(.opacity.combined(with: .scale(scale: 0.85, anchor: .leading)))
                    }
                }
                .foregroundStyle(activeFilterCount > 0 ? Color.ftdAccentOrange : Color.ftdTextSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .stroke(activeFilterCount > 0 ? Color.ftdAccentOrange : Color.ftdBorder, lineWidth: 1)
                )
            }
            .buttonStyle(.plain)

            Button { exportBookings() } label: {
                HStack(spacing: isSearchFocused ? 0 : 4) {
                    Image(systemName: "arrow.down.circle")
                        .font(.caption)
                    if !isSearchFocused {
                        Text("Export")
                            .font(.ftdBodySM)
                            .fixedSize()
                            .transition(.opacity.combined(with: .scale(scale: 0.85, anchor: .leading)))
                    }
                }
                .foregroundStyle(Color.ftdCreditGreen)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.field).stroke(Color.ftdCreditGreen, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
        .animation(.easeInOut(duration: 0.22), value: isSearchFocused)
    }

    private func exportBookings() {
        guard !filteredBookings.isEmpty else { return }
        var csv = "Ref No,Origin,Destination,Airline,PNR,Depart Date,Status,Total Fare,Net Price\n"
        for b in filteredBookings {
            let row = [
                b.uniqueRefNo ?? "",
                b.origin ?? "", b.destination ?? "",
                b.carrierName ?? b.carrier ?? "",
                b.pnr ?? "",
                b.departureDate ?? "",
                b.status ?? "",
                b.totalFare ?? "",
                b.agentNetPrice ?? ""
            ].map { "\"\($0)\"" }.joined(separator: ",")
            csv += row + "\n"
        }
        let tmp = FileManager.default.temporaryDirectory.appendingPathComponent("bookings_export.csv")
        try? csv.write(to: tmp, atomically: true, encoding: .utf8)
        let av = UIActivityViewController(activityItems: [tmp], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            root.present(av, animated: true)
        }
    }

    // MARK: - Active Filter Chips

    private var activeFilterCount: Int { activeFilterChipsData.count }

    private var activeFilterChipsData: [(label: String, clear: () -> Void)] {
        var chips: [(label: String, clear: () -> Void)] = []
        switch viewModel.selectedTab {
        case .flight:
            if !viewModel.flightFromDate.isEmpty   { chips.append(("From: \(viewModel.flightFromDate)",      { viewModel.flightFromDate = "" })) }
            if !viewModel.flightToDate.isEmpty     { chips.append(("To: \(viewModel.flightToDate)",          { viewModel.flightToDate = "" })) }
            if !viewModel.flightPNR.isEmpty        { chips.append(("PNR: \(viewModel.flightPNR)",            { viewModel.flightPNR = "" })) }
            if !viewModel.flightAirline.isEmpty    { chips.append(("Airline: \(viewModel.flightAirline)",    { viewModel.flightAirline = "" })) }
            if !viewModel.flightStatus.isEmpty     { chips.append(("Status: \(viewModel.flightStatus)",      { viewModel.flightStatus = "" })) }
            if !viewModel.flightName.isEmpty       { chips.append(("Name: \(viewModel.flightName)",          { viewModel.flightName = "" })) }
            if !viewModel.flightBookingId.isEmpty  { chips.append(("Booking ID: \(viewModel.flightBookingId)", { viewModel.flightBookingId = "" })) }
        case .bus:
            if !viewModel.busFromDate.isEmpty     { chips.append(("From: \(viewModel.busFromDate)",      { viewModel.busFromDate = "" })) }
            if !viewModel.busToDate.isEmpty       { chips.append(("To: \(viewModel.busToDate)",          { viewModel.busToDate = "" })) }
            if !viewModel.busRefNo.isEmpty        { chips.append(("Ref: \(viewModel.busRefNo)",          { viewModel.busRefNo = "" })) }
            if !viewModel.busPassName.isEmpty     { chips.append(("Pax: \(viewModel.busPassName)",       { viewModel.busPassName = "" })) }
            if !viewModel.busStatus.isEmpty       { chips.append(("Status: \(viewModel.busStatus)",      { viewModel.busStatus = "" })) }
        case .cab:
            if !viewModel.cabFromDate.isEmpty     { chips.append(("From: \(viewModel.cabFromDate)",      { viewModel.cabFromDate = "" })) }
            if !viewModel.cabToDate.isEmpty       { chips.append(("To: \(viewModel.cabToDate)",          { viewModel.cabToDate = "" })) }
            if !viewModel.cabPNR.isEmpty          { chips.append(("PNR: \(viewModel.cabPNR)",            { viewModel.cabPNR = "" })) }
            if !viewModel.cabStatus.isEmpty       { chips.append(("Status: \(viewModel.cabStatus)",      { viewModel.cabStatus = "" })) }
            if !viewModel.cabName.isEmpty         { chips.append(("Name: \(viewModel.cabName)",          { viewModel.cabName = "" })) }
        case .hotel:
            if !viewModel.hotelCheckIn.isEmpty    { chips.append(("In: \(viewModel.hotelCheckIn)",       { viewModel.hotelCheckIn = "" })) }
            if !viewModel.hotelCheckOut.isEmpty   { chips.append(("Out: \(viewModel.hotelCheckOut)",     { viewModel.hotelCheckOut = "" })) }
            if !viewModel.hotelPNR.isEmpty        { chips.append(("PNR: \(viewModel.hotelPNR)",          { viewModel.hotelPNR = "" })) }
            if !viewModel.hotelRefNo.isEmpty      { chips.append(("Ref: \(viewModel.hotelRefNo)",        { viewModel.hotelRefNo = "" })) }
            if !viewModel.hotelStatus.isEmpty     { chips.append(("Status: \(viewModel.hotelStatus)",    { viewModel.hotelStatus = "" })) }
        case .insurance:
            if !viewModel.insOnwardDate.isEmpty   { chips.append(("Onward: \(viewModel.insOnwardDate)",  { viewModel.insOnwardDate = "" })) }
            if !viewModel.insReturnDate.isEmpty   { chips.append(("Return: \(viewModel.insReturnDate)",  { viewModel.insReturnDate = "" })) }
            if !viewModel.insCountry.isEmpty      { chips.append(("Country: \(viewModel.insCountry)",    { viewModel.insCountry = "" })) }
            if !viewModel.insStatus.isEmpty       { chips.append(("Status: \(viewModel.insStatus)",      { viewModel.insStatus = "" })) }
            if !viewModel.insType.isEmpty         { chips.append(("Type: \(viewModel.insType)",          { viewModel.insType = "" })) }
            if !viewModel.insReference.isEmpty    { chips.append(("Ref: \(viewModel.insReference)",      { viewModel.insReference = "" })) }
        case .visa:
            if !viewModel.visaOnwardDate.isEmpty  { chips.append(("Onward: \(viewModel.visaOnwardDate)", { viewModel.visaOnwardDate = "" })) }
            if !viewModel.visaReturnDate.isEmpty  { chips.append(("Return: \(viewModel.visaReturnDate)", { viewModel.visaReturnDate = "" })) }
            if !viewModel.visaCountry.isEmpty     { chips.append(("Country: \(viewModel.visaCountry)",   { viewModel.visaCountry = "" })) }
            if !viewModel.visaReference.isEmpty   { chips.append(("Ref: \(viewModel.visaReference)",     { viewModel.visaReference = "" })) }
        case .esim:
            if !viewModel.esimFromDate.isEmpty    { chips.append(("From: \(viewModel.esimFromDate)",     { viewModel.esimFromDate = "" })) }
            if !viewModel.esimToDate.isEmpty      { chips.append(("To: \(viewModel.esimToDate)",         { viewModel.esimToDate = "" })) }
            if !viewModel.esimReference.isEmpty   { chips.append(("Ref: \(viewModel.esimReference)",     { viewModel.esimReference = "" })) }
        }
        return chips
    }

    @ViewBuilder
    private var activeFilterChipsRow: some View {
        if !activeFilterChipsData.isEmpty {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    ForEach(activeFilterChipsData, id: \.label) { chip in
                        HStack(spacing: 4) {
                            Text(chip.label)
                                .font(.ftdLabelXS)
                                .foregroundStyle(Color.ftdAccentOrange)
                            Button {
                                chip.clear()
                                currentPage = 1
                                Task { await viewModel.search() }
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(Color.ftdAccentOrange)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, 5)
                        .background(Color.ftdAccentOrange.opacity(0.08))
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(Color.ftdAccentOrange.opacity(0.3), lineWidth: 1))
                    }

                    Button {
                        viewModel.resetFilters()
                        searchQuery = ""
                        currentPage = 1
                        Task { await viewModel.search() }
                    } label: {
                        Text("Clear All")
                            .font(.ftdLabelXS)
                            .foregroundStyle(Color.ftdDestructiveRed)
                            .padding(.horizontal, DesignTokens.Spacing.sm)
                            .padding(.vertical, 5)
                            .background(Color.ftdDestructiveRed.opacity(0.08))
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.sm)
            }
            .background(Color.ftdCardBackground)
        }
    }

    // MARK: - Filter Sheet

    private var filterSheet: some View {
        NavigationStack {
            ScrollView(.vertical, showsIndicators: false) {
                LazyVGrid(
                    columns: [GridItem(.flexible()), GridItem(.flexible())],
                    spacing: DesignTokens.Spacing.sm
                ) {
                    switch viewModel.selectedTab {
                    case .flight:    flightFilters
                    case .bus:       busFilters
                    case .cab:       cabFilters
                    case .hotel:     hotelFilters
                    case .insurance: insuranceFilters
                    case .visa:      visaFilters
                    case .esim:      esimFilters
                    }
                }
                .padding(DesignTokens.Spacing.lg)
            }
            .background(Color.ftdInputBackground)
            .safeAreaInset(edge: .bottom) {
                FTDPrimaryButton(title: viewModel.isLoading ? "Loading…" : "Apply Filters") {
                    Task {
                        currentPage = 1
                        await viewModel.search()
                        isFilterSheetPresented = false
                        scrollToTop.toggle()
                    }
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.sm)
                .padding(.bottom, DesignTokens.Spacing.lg)
                .background(Color.ftdInputBackground)
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { isFilterSheetPresented = false }
                        .foregroundStyle(Color.ftdTextSecondary)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") {
                        viewModel.resetFilters()
                        searchQuery = ""
                    }
                    .foregroundStyle(Color.ftdDestructiveRed)
                }
            }
        }
        .sheet(isPresented: $showDatePicker) { datePickerSheet }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var datePickerSheet: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Text(pickerLabel)
                .font(.headline).fontWeight(.bold)
                .foregroundStyle(Color.ftdTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.lg)
            DatePicker("", selection: $pickerDate, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Color.ftdAccentOrange)
                .labelsHidden()
                .padding(.horizontal, DesignTokens.Spacing.lg)
            FTDPrimaryButton(title: "Done") {
                onDatePicked?(Self.apiFmt.string(from: pickerDate))
                showDatePicker = false
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.lg)
        }
        .presentationDetents([.fraction(0.78)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.ftdCardBackground)
    }

    private func showPicker(_ label: String, current: String, assign: @escaping (String) -> Void) {
        pickerLabel   = label
        pickerDate    = Self.apiFmt.date(from: current) ?? Date()
        onDatePicked  = assign
        showDatePicker = true
    }

    // MARK: - Filter Fields per Tab

    @ViewBuilder private var flightFilters: some View {
        dateFilterField("From Date",  value: viewModel.flightFromDate)  { showPicker("From Date",   current: viewModel.flightFromDate)  { viewModel.flightFromDate  = $0 } }
        dateFilterField("To Date",    value: viewModel.flightToDate)    { showPicker("To Date",     current: viewModel.flightToDate)    { viewModel.flightToDate    = $0 } }
        filterField("Airline",     placeholder: "Airline code",       text: $viewModel.flightAirline)
        statusDropdownField(text: $viewModel.flightStatus)
        filterField("PNR",         placeholder: "PNR",                text: $viewModel.flightPNR)
        filterField("Pax Name",    placeholder: "Passenger",          text: $viewModel.flightName)
        filterField("Booking ID",  placeholder: "Eg: SZ2312211111",   text: $viewModel.flightBookingId)
    }

    @ViewBuilder private var busFilters: some View {
        dateFilterField("From Date",    value: viewModel.busFromDate)    { showPicker("From Date",    current: viewModel.busFromDate)    { viewModel.busFromDate    = $0 } }
        dateFilterField("To Date",      value: viewModel.busToDate)      { showPicker("To Date",      current: viewModel.busToDate)      { viewModel.busToDate      = $0 } }
        dateFilterField("Depart Date",  value: viewModel.busDepartDate)  { showPicker("Depart Date",  current: viewModel.busDepartDate)  { viewModel.busDepartDate  = $0 } }
        dateFilterField("Booking Date", value: viewModel.busBkgDate)     { showPicker("Booking Date", current: viewModel.busBkgDate)     { viewModel.busBkgDate     = $0 } }
        filterField("Ref No",     placeholder: "Reference",  text: $viewModel.busRefNo)
        filterField("Pass Name",  placeholder: "Passenger",  text: $viewModel.busPassName)
        filterField("Status",     placeholder: "Status",     text: $viewModel.busStatus)
    }

    @ViewBuilder private var cabFilters: some View {
        dateFilterField("From Date",    value: viewModel.cabFromDate)    { showPicker("From Date",    current: viewModel.cabFromDate)    { viewModel.cabFromDate    = $0 } }
        dateFilterField("To Date",      value: viewModel.cabToDate)      { showPicker("To Date",      current: viewModel.cabToDate)      { viewModel.cabToDate      = $0 } }
        dateFilterField("Depart Date",  value: viewModel.cabDepartDate)  { showPicker("Depart Date",  current: viewModel.cabDepartDate)  { viewModel.cabDepartDate  = $0 } }
        dateFilterField("Booking Date", value: viewModel.cabBkgDate)     { showPicker("Booking Date", current: viewModel.cabBkgDate)     { viewModel.cabBkgDate     = $0 } }
        filterField("PNR",        placeholder: "PNR",       text: $viewModel.cabPNR)
        filterField("Status",     placeholder: "Status",    text: $viewModel.cabStatus)
        filterField("First Name", placeholder: "Passenger", text: $viewModel.cabName)
    }

    @ViewBuilder private var hotelFilters: some View {
        dateFilterField("Check-In",  value: viewModel.hotelCheckIn)   { showPicker("Check-In",  current: viewModel.hotelCheckIn)   { viewModel.hotelCheckIn  = $0 } }
        dateFilterField("Check-Out", value: viewModel.hotelCheckOut)  { showPicker("Check-Out", current: viewModel.hotelCheckOut)  { viewModel.hotelCheckOut = $0 } }
        filterField("PNR",    placeholder: "PNR",       text: $viewModel.hotelPNR)
        filterField("Ref No", placeholder: "Reference", text: $viewModel.hotelRefNo)
        filterField("Status", placeholder: "Status",    text: $viewModel.hotelStatus)
    }

    @ViewBuilder private var insuranceFilters: some View {
        dateFilterField("Onward Date", value: viewModel.insOnwardDate) { showPicker("Onward Date", current: viewModel.insOnwardDate) { viewModel.insOnwardDate = $0 } }
        dateFilterField("Return Date", value: viewModel.insReturnDate) { showPicker("Return Date", current: viewModel.insReturnDate) { viewModel.insReturnDate = $0 } }
        filterField("Country",   placeholder: "Country name", text: $viewModel.insCountry)
        filterField("Status",    placeholder: "Status",       text: $viewModel.insStatus)
        filterField("Type",      placeholder: "Type",         text: $viewModel.insType)
        filterField("Reference", placeholder: "Ref no",       text: $viewModel.insReference)
    }

    @ViewBuilder private var visaFilters: some View {
        dateFilterField("Onward Date", value: viewModel.visaOnwardDate) { showPicker("Onward Date", current: viewModel.visaOnwardDate) { viewModel.visaOnwardDate = $0 } }
        dateFilterField("Return Date", value: viewModel.visaReturnDate) { showPicker("Return Date", current: viewModel.visaReturnDate) { viewModel.visaReturnDate = $0 } }
        filterField("Country",   placeholder: "Country name", text: $viewModel.visaCountry)
        filterField("Reference", placeholder: "Ref no",       text: $viewModel.visaReference)
    }

    @ViewBuilder private var esimFilters: some View {
        dateFilterField("From Date", value: viewModel.esimFromDate) { showPicker("From Date", current: viewModel.esimFromDate) { viewModel.esimFromDate = $0 } }
        dateFilterField("To Date",   value: viewModel.esimToDate)   { showPicker("To Date",   current: viewModel.esimToDate)   { viewModel.esimToDate   = $0 } }
        filterField("Reference", placeholder: "Ref no", text: $viewModel.esimReference)
    }

    private func filterField(_ label: String, placeholder: String, text: Binding<String>) -> some View {
        FTDTextField(label: label, placeholder: placeholder, text: text)
    }

    private static let flightStatusOptions = ["Confirmed", "Rejected", "Pending"]

    private func statusDropdownField(text: Binding<String>) -> some View {
        Menu {
            ForEach(Self.flightStatusOptions, id: \.self) { option in
                Button {
                    text.wrappedValue = text.wrappedValue == option ? "" : option
                } label: {
                    Label(option, systemImage: text.wrappedValue == option ? "checkmark" : "")
                }
            }
        } label: {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                ftdRequiredLabel("Status")
                    .font(.caption)
                HStack {
                    Text(text.wrappedValue.isEmpty ? "Select Status" : text.wrappedValue)
                        .font(.ftdBodySM)
                        .foregroundStyle(text.wrappedValue.isEmpty ? Color.ftdTextSecondary : Color.ftdTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12))
                        .foregroundStyle(Color.ftdAccentOrange)
                }
            }
            .ftdInputContainer()
        }
        .frame(maxWidth: .infinity)
    }

    private func dateFilterField(_ label: String, value: String, onTap: @escaping () -> Void) -> some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                ftdRequiredLabel(label)
                    .font(.caption)
                HStack {
                    Text(value.isEmpty ? "Select Date" : value)
                        .font(.ftdBodySM)
                        .foregroundStyle(value.isEmpty ? Color.ftdTextSecondary : Color.ftdTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Image(systemName: "calendar")
                        .font(.system(size: 14))
                        .foregroundStyle(Color.ftdAccentOrange)
                }
            }
            .ftdInputContainer()
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    // MARK: - Content Area

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading {
            loadingView
        } else if let err = viewModel.error {
            errorView(err)
        } else if viewModel.selectedTab != .flight {
            comingSoonView
        } else if filteredBookings.isEmpty {
            emptyView
        } else {
            flightList
        }
    }

    // MARK: - Inline Search Filter

    private var filteredBookings: [AgentFlightBooking] {
        let q = searchQuery.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return viewModel.flightBookings }
        return viewModel.flightBookings.filter { b in
            let fields = [
                b.uniqueRefNo, b.pnr, b.carrier, b.carrierName,
                b.origin, b.destination, b.originCity, b.destinationCity,
                b.totalFare, b.agentNetPrice, b.totalAmount, b.totalNet,
                b.onwardTotalNet, b.returnTotalNet
            ].compactMap { $0?.lowercased() }
            if fields.contains(where: { $0.contains(q) }) { return true }
            return b.passengers?.contains { $0.fullName.lowercased().contains(q) } ?? false
        }
    }

    // MARK: - Flight List

    private var pagedBookings: [AgentFlightBooking] {
        let start = (currentPage - 1) * pageSize
        let end   = min(start + pageSize, filteredBookings.count)
        guard start < end else { return [] }
        return Array(filteredBookings[start..<end])
    }

    private var totalPages: Int {
        max(1, (filteredBookings.count + pageSize - 1) / pageSize)
    }

    private var flightList: some View {
        VStack(spacing: 0) {
            // entries label
            let total = filteredBookings.count
            let start = (currentPage - 1) * pageSize + 1
            let end   = min(currentPage * pageSize, total)
            HStack {
                Text("Showing \(start)–\(end) of \(total) entries")
                    .font(.ftdLabelXS)
                    .foregroundStyle(Color.ftdTextSecondary)
                Spacer()
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.md)
            .padding(.bottom, DesignTokens.Spacing.xs)

            LazyVStack(spacing: DesignTokens.Spacing.md) {
                ForEach(pagedBookings) { booking in
                    flightCard(booking)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)

            paginationRow
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.md)
                .padding(.bottom, DesignTokens.Spacing.xxl)
        }
        .alert("Flight Details", isPresented: Binding(get: { alertBooking != nil }, set: { _ in alertBooking = nil }), presenting: alertBooking) { _ in
            Button("OK", role: .cancel) { alertBooking = nil }
        } message: { b in
            Text(alertMessage(b))
        }
    }

    private func alertMessage(_ b: AgentFlightBooking) -> String {
        var lines: [String] = []
        let route = "\(b.origin ?? "-") → \(b.destination ?? "-")"
        if let oc = b.originCity, let dc = b.destinationCity, !oc.isEmpty, !dc.isEmpty {
            lines.append("\(route) (\(oc) → \(dc))")
        } else {
            lines.append(route)
        }
        if let airline = b.carrierName ?? b.carrier { lines.append("Airline: \(airline)") }
        if let pnr = b.pnr                          { lines.append("PNR: \(pnr)") }
        if let ref = b.uniqueRefNo                  { lines.append("Ref No: \(ref)") }
        if let trip = b.tripType                    { lines.append("Trip: \(trip)") }
        if let date = fmtDate(b.departureDate)      { lines.append("Depart: \(date)") }
        if let time = fmtTime(b.departureTime)      { lines.append("Time: \(time)") }
        if let bDate = b.bookingDate                { lines.append("Booked: \(bDate)") }
        if let fare = b.fareTypeDesc                { lines.append("Fare Type: \(fare)") }
        if let total = b.totalFare                  { lines.append("Total Fare: ₹\(total)") }
        if let net = b.agentNetPrice                { lines.append("Net Price: ₹\(net)") }
        if let pax = b.passengers, !pax.isEmpty     { lines.append("Passengers: \(pax.count)") }
        return lines.joined(separator: "\n")
    }

    private var paginationRow: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            if currentPage > 1 {
                Button {
                    withAnimation { currentPage -= 1 }
                    scrollToTop.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 11, weight: .semibold))
                        Text("Previous")
                            .font(.ftdLabelSM)
                    }
                    .foregroundStyle(Color.ftdAccentOrange)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .background(Color.ftdAccentOrange.opacity(0.08))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.ftdAccentOrange.opacity(0.4), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }

            Spacer()

            Text("Page \(currentPage) of \(totalPages)")
                .font(.ftdLabelXS)
                .foregroundStyle(Color.ftdTextSecondary)

            Spacer()

            if currentPage < totalPages {
                Button {
                    withAnimation { currentPage += 1 }
                    scrollToTop.toggle()
                } label: {
                    HStack(spacing: 4) {
                        Text("Next")
                            .font(.ftdLabelSM)
                        Image(systemName: "chevron.right")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundStyle(Color.ftdAccentOrange)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .background(Color.ftdAccentOrange.opacity(0.08))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.ftdAccentOrange.opacity(0.4), lineWidth: 1))
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Flight Card

    private func flightCard(_ b: AgentFlightBooking) -> some View {
        let info    = tripTypeInfo(for: b.tripType)
        let isRound = info.isRound
        let isIntl  = b.serviceType == 2

        return VStack(alignment: .leading, spacing: 0) {

            // ─── Route Header (tappable) ───
            // Badge in HStack so "to" city trails exactly to the badge leading edge — no overlap
            Button { alertBooking = b } label: {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                    VStack(alignment: .leading, spacing: 6) {
                        routeRow(
                            from: b.originCity ?? b.origin,
                            to: b.destinationCity ?? b.destination,
                            icon: "airplane",
                            isIntl: isIntl
                        )
                        if isRound {
                            Rectangle()
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 0.5)
                            routeRow(
                                from: b.returnBooking?.originCity ?? b.returnBooking?.origin ?? b.destinationCity ?? b.destination,
                                to: b.returnBooking?.destinationCity ?? b.returnBooking?.destination ?? b.originCity ?? b.origin,
                                icon: "airplane",
                                isIntl: false,
                                mirrored: true
                            )
                        }
                        if let bd = fmtDate(b.bookingDate) {
                            HStack(spacing: 3) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 9))
                                    .foregroundStyle(.white.opacity(0.6))
                                Text("Booked: \(bd)")
                                    .font(.system(size: 10))
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    statusBadge(b.status)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.ftdSideMenuLogout)
            }
            .buttonStyle(.plain)

            // ─── Info Grid (3 cols: Airline+FareType | PNR | Departure) ───
            VStack(spacing: 0) {
                // Outbound leg
                HStack(alignment: .top, spacing: 0) {
                    airlineCell(airline: b.carrierName ?? b.carrier, fareType: b.fareTypeDesc)
                    HStack(alignment: .top, spacing: 0) {
                        infoCell("PNR",       value: b.pnr, valueColor: statusColor(b.status))
                        infoCell("Departure", value: departureLine(date: b.departureDate, time: b.departureTime), lineLimit: 1)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, DesignTokens.Spacing.inputVertical)

                // Return leg — uses return_booking object, not CSV splitting
                if isRound, let ret = b.returnBooking {
                    Divider().padding(.horizontal, 14)
                    HStack(alignment: .top, spacing: 0) {
                        airlineCell(airline: ret.validatingCarrierName ?? ret.carrierName ?? b.carrierName ?? b.carrier, fareType: ret.fareTypeDesc ?? b.fareTypeDesc)
                        HStack(alignment: .top, spacing: 0) {
                            infoCell("PNR",       value: ret.pnr, valueColor: statusColor(b.status))
                            infoCell("Departure", value: departureLine(date: ret.departureDate, time: ret.departureTime), lineLimit: 1)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, DesignTokens.Spacing.inputVertical)
                }
            }

            // ─── Passengers (2×2 grid, all shown, no titles/type) ───
            if let pax = b.passengers, !pax.isEmpty {
                Divider().padding(.horizontal, 14)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text("Passengers")
                        .font(.caption2).fontWeight(.semibold)
                        .foregroundStyle(Color.ftdTextSecondary)
                    LazyVGrid(
                        columns: [GridItem(.flexible()), GridItem(.flexible())],
                        spacing: DesignTokens.Spacing.xs
                    ) {
                        ForEach(Array(pax.enumerated()), id: \.offset) { _, p in
                            HStack(spacing: 4) {
                                Image(systemName: "person.fill")
                                    .font(.caption2)
                                    .foregroundStyle(Color.ftdAccentOrange)
                                Text(cleanPassengerName(p.fullName))
                                    .font(.caption)
                                    .foregroundStyle(Color.ftdTextPrimary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, DesignTokens.Spacing.inputVertical)
            }

            Divider().padding(.horizontal, 14)

            // ─── Footer: Fare Amounts ───
            HStack(alignment: .top) {
                Spacer()
                HStack(spacing: DesignTokens.Spacing.md) {
                    if let fare = b.totalAmount ?? b.totalFare, !fare.isEmpty {
                        fareChip(label: "Total", value: fare, color: Color.ftdTextPrimary)
                    }
                    if let net1 = b.onwardTotalNet, !net1.isEmpty {
                        let hasNet2 = isRound && !(b.returnTotalNet ?? "").isEmpty
                        fareChip(label: hasNet2 ? "Net 1" : "Net", value: net1, color: Color.ftdAccentTeal)
                    } else if let net = b.totalNet ?? b.agentNetPrice, !net.isEmpty {
                        fareChip(label: "Net", value: net, color: Color.ftdAccentTeal)
                    }
                    if isRound, let net2 = b.returnTotalNet, !net2.isEmpty {
                        fareChip(label: "Net 2", value: net2, color: Color.ftdAccentTeal)
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, DesignTokens.Spacing.inputVertical)
        }
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.cardLg))
        .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.cardLg).stroke(Color.ftdBorder, lineWidth: 0.5))
        .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
    }

    // MARK: - Card Sub-components

    private func routeRow(from: String?, to: String?, icon: String, isIntl: Bool, mirrored: Bool = false) -> some View {
        HStack(spacing: 4) {
            Text(from ?? "-")
                .font(.subheadline).fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            VStack(spacing: 2) {
                if isIntl {
                    Image(systemName: "globe.americas")
                        .font(.system(size: 8))
                        .foregroundStyle(Color.ftdAccentOrange)
                }
                Image(systemName: icon)
                    .font(.system(size: 13))
                    .foregroundStyle(Color.ftdAccentOrange)
                    .scaleEffect(x: mirrored ? -1 : 1, y: 1)
            }

            Text(to ?? "-")
                .font(.subheadline).fontWeight(.bold)
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.65)
        }
    }

    private func statusBadge(_ status: String?) -> some View {
        let color = statusColor(status)
        let s = status ?? "-"
        return Text(s.uppercased())
            .font(.system(size: 9, weight: .bold))
            .tracking(0.5)
            .foregroundStyle(color)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, 4)
            .background(color.opacity(0.22))
            .clipShape(Capsule())
            .overlay(Capsule().stroke(color.opacity(0.55), lineWidth: 1))
    }

    private func statusColor(_ status: String?) -> Color {
        switch (status ?? "").lowercased().trimmingCharacters(in: .whitespaces) {
        case "success", "confirmed", "completed", "holdconfirm", "booked":
            return .green
        case "rejected", "holduna", "holdunc", "cancelled", "failed":
            return Color.ftdDestructiveRed
        case "hold", "pending", "inprogress", "check", "hc pending":
            return Color.ftdAccentOrange
        default:
            return Color.ftdTextSecondary
        }
    }

    private func airlineCell(airline: String?, fareType: String?) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            Text("Airline")
                .font(.caption2)
                .foregroundStyle(Color.ftdTextSecondary)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(airline ?? "-")
                    .font(.caption).fontWeight(.semibold)
                    .foregroundStyle(Color.ftdTextPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                if let ft = fareType, !ft.isEmpty {
                    Text("(\(ft))")
                        .font(.caption2)
                        .foregroundStyle(Color.ftdAccentTeal)
                        .lineLimit(1)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func infoCell(
        _ title: String,
        value: String?,
        valueColor: Color = Color.ftdTextPrimary,
        lineLimit: Int? = 1
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            Text(title)
                .font(.caption2).foregroundStyle(Color.ftdTextSecondary)
            Text(value ?? "-")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(valueColor)
                .lineLimit(lineLimit)
                .fixedSize(horizontal: false, vertical: true)
                .minimumScaleFactor((lineLimit ?? 2) > 1 ? 1.0 : 0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func fareChip(label: String, value: String, color: Color) -> some View {
        let values = splitCSV(value)
        return VStack(alignment: .trailing, spacing: 2) {
            Text(label)
                .font(.caption2).foregroundStyle(Color.ftdTextSecondary)
            ForEach(values.isEmpty ? [value] : values, id: \.self) { v in
                Text("₹\(v)")
                    .font(.caption).fontWeight(.bold)
                    .foregroundStyle(color)
            }
        }
    }

    private func actionButton(_ title: String, color: Color) -> some View {
        Button { } label: {
            Text(title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(color)
                .padding(.horizontal, DesignTokens.Spacing.sm)
                .padding(.vertical, 5)
                .background(color.opacity(0.1))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(color.opacity(0.3), lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    private func fmtDate(_ raw: String?) -> String? {
        guard let raw, !raw.isEmpty else { return nil }
        let src = DateFormatter(); src.dateFormat = "yyyy-MM-dd"; src.locale = .init(identifier: "en_US_POSIX")
        let dst = DateFormatter(); dst.dateFormat = "dd MMM yy"
        return src.date(from: raw).map { dst.string(from: $0) } ?? raw
    }

    private func fmtTime(_ raw: String?) -> String? {
        guard let raw, raw.count >= 3 else { return raw }
        let trimmed = raw.trimmingCharacters(in: .whitespaces)
        if trimmed.count == 4 {
            return "\(trimmed.prefix(2)):\(trimmed.suffix(2))"
        }
        return trimmed
    }

    // triptype API values: "R" = round trip, "S" = one way
    private func tripTypeInfo(for tripType: String?) -> (icon: String, isRound: Bool, isIntl: Bool) {
        let t = (tripType ?? "").trimmingCharacters(in: .whitespaces)
        let lower = t.lowercased()
        let isRound = lower == "r" || lower.contains("round") || lower == "2" || lower == "4"
        let isIntl  = lower.contains("international") || lower.contains("intl") || lower == "3" || lower == "4"
        let icon    = isRound ? "arrow.left.arrow.right" : "airplane"
        return (icon: icon, isRound: isRound, isIntl: isIntl)
    }

    private func splitCSV(_ value: String?) -> [String] {
        guard let value, !value.isEmpty else { return [] }
        return value.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
    }

    // Returns leg[i] from a comma-separated string; falls back to first value if leg i doesn't exist
    private func legValue(_ csv: String?, leg: Int) -> String? {
        let parts = splitCSV(csv)
        guard !parts.isEmpty else { return nil }
        return leg < parts.count ? parts[leg] : parts[0]
    }

    private func departureLine(date: String?, time: String?) -> String? {
        let parts = [fmtDate(date), fmtTime(time)].compactMap { $0 }.filter { !$0.isEmpty }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }

    private func cleanPassengerName(_ name: String) -> String {
        // Handle both "Mr." (with dot) and "Mr" (no dot) title formats
        let prefixes = ["mr. ", "mrs. ", "ms. ", "miss. ", "dr. ", "prof. ", "master. ", "mstr. ", "mst. ",
                        "mr ", "mrs ", "ms ", "miss ", "dr ", "prof ", "master ", "mstr ", "mst "]
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        let lower = trimmed.lowercased()
        for prefix in prefixes {
            if lower.hasPrefix(prefix) {
                return String(trimmed.dropFirst(prefix.count)).trimmingCharacters(in: .whitespaces)
            }
        }
        return trimmed
    }

    // MARK: - State Views

    private var loadingView: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ProgressView().scaleEffect(1.3).tint(Color.ftdAccentOrange)
            Text(String(localized: "Loading bookings…"))
                .font(.subheadline).foregroundStyle(Color.ftdTextSecondary)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(Color.ftdInputBackground)
    }

    private var emptyView: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "ticket")
                .font(.ftdHeroIcon)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.3))
            Text(String(localized: "No bookings found"))
                .font(.title3).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextSecondary)
            Text(String(localized: "Try adjusting the filter dates."))
                .font(.subheadline).multilineTextAlignment(.center)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.7))
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(Color.ftdInputBackground)
    }

    private var comingSoonView: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: viewModel.selectedTab.icon)
                .font(.ftdHeroIcon)
                .foregroundStyle(Color.ftdAccentOrange.opacity(0.3))
            Text("\(viewModel.selectedTab.rawValue) Bookings")
                .font(.title3).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextSecondary)
            Text(String(localized: "Coming soon"))
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.6))
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(Color.ftdInputBackground)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Image(systemName: "exclamationmark.triangle")
                .font(.ftdHeroIcon)
                .foregroundStyle(Color.ftdAccentOrange.opacity(0.6))
            Text(message)
                .font(.subheadline).multilineTextAlignment(.center)
                .foregroundStyle(Color.ftdTextSecondary)
                .padding(.horizontal, 32)
            Button(String(localized: "Retry")) {
                Task { await viewModel.search() }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.ftdAccentOrange)
        }
        .frame(maxWidth: .infinity, minHeight: 300)
        .background(Color.ftdInputBackground)
    }
}
