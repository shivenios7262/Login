import SwiftUI

// MARK: - Preference Key

private struct HeroCollapsedKey: PreferenceKey {
    static var defaultValue: Bool = false
    static func reduce(value: inout Bool, nextValue: () -> Bool) { value = nextValue() }
}

// MARK: - RefundView

struct RefundView: View {
    @Bindable var viewModel: RefundViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var isFilterSheetPresented = false
    @State private var expandedIds = Set<UUID>()

    @State private var cancelFromDateObj = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
    @State private var cancelToDateObj   = Date()
    @State private var refundFromDateObj = Date()
    @State private var refundToDateObj   = Date()

    @State private var showCancelFromPicker = false
    @State private var showCancelToPicker   = false
    @State private var showRefundFromPicker = false
    @State private var showRefundToPicker   = false

    @FocusState private var isSearchFocused: Bool
    @State private var isHeroCollapsed = false
    @State private var scrollToTop = false

    private static let apiFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private let heroHeight: CGFloat = 160

    var body: some View {
        ZStack(alignment: .top) {
            Color.ftdInputBackground.ignoresSafeArea()

            ScrollViewReader { proxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Color.clear.frame(height: 0).id("refundTop")
                    parallaxHero

                    Section {
                        contentSection
                            .background(Color.ftdInputBackground)
                            .animation(.easeInOut(duration: 0.35), value: viewModel.isLoading)
                            .animation(.easeInOut(duration: 0.35), value: viewModel.filteredRecords.count)
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
                                let headerY = geo.frame(in: .named("refundScroll")).minY
                                Color.ftdCardBackground
                                    .ignoresSafeArea(edges: .top)
                                    .preference(key: HeroCollapsedKey.self, value: headerY < heroHeight * 0.4)
                            }
                        )
                        .animation(.easeInOut(duration: 0.2), value: isHeroCollapsed)
                        .zIndex(1)
                    }
                }
            }
            .coordinateSpace(name: "refundScroll")
            .onPreferenceChange(HeroCollapsedKey.self) { isHeroCollapsed = $0 }
            .onChange(of: scrollToTop) { _, _ in
                withAnimation { proxy.scrollTo("refundTop", anchor: .top) }
            }
            } // ScrollViewReader

        }
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack {
                Button { dismiss() } label: {
                    Image("back")
                        .renderingMode(.template)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(Color.ftdTextPrimary)
                        .frame(width: 36, height: 36)
                        .background(Color.ftdInputBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)

                Spacer()

                Text("My Refunds")
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
        .task(id: viewModel.autoLoadKey) { await viewModel.search() }
        .sheet(isPresented: $isFilterSheetPresented) { filterSheet }
        .sheet(isPresented: $viewModel.showExportSheet) {
            if let url = viewModel.exportURL {
                ActivityShareView(url: url)
                    .presentationDetents([.medium])
            }
        }
        .onChange(of: viewModel.selectedTab) { _, _ in
            cancelFromDateObj = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
            cancelToDateObj   = Date()
            refundFromDateObj = Date()
            refundToDateObj   = Date()
            expandedIds       = []
            scrollToTop.toggle()
        }
    }

    // MARK: - Parallax Hero

    private var parallaxHero: some View {
        GeometryReader { geo in
            let minY = geo.frame(in: .named("refundScroll")).minY
            let isOverscrolling = minY > 0

             FTDRemoteImage(url: FTDImageURL.myRefundBanner, contentMode: .fill)
//            Image("dottedMap")
//                .resizable()
//                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: isOverscrolling ? heroHeight + minY : heroHeight)
                .offset(y: isOverscrolling ? -minY : minY * 0.4)
                .clipped()
        }
        .frame(height: heroHeight)
    }

    // MARK: - Tab Bar

    private var customTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(RefundTab.allCases) { tab in
                    let isSelected = viewModel.selectedTab == tab
                    Button {
                        viewModel.switchTab(tab)
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
                Image("search")
                    .font(.caption)
                    .foregroundStyle(isSearchFocused ? Color.ftdAccentOrange : Color.ftdTextSecondary)
                TextField("Search refunds", text: $viewModel.searchQuery)
                    .font(.ftdBodySM)
                    .autocorrectionDisabled()
                    .focused($isSearchFocused)
                if !viewModel.searchQuery.isEmpty {
                    Button { viewModel.searchQuery = "" } label: {
                        Image("cancel")
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

            Button { viewModel.triggerExport() } label: {
                HStack(spacing: isSearchFocused ? 0 : 4) {
                    Image("download")
                        .renderingMode(.template)
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

    // MARK: - Active Filter Chips

    private var activeFilterCount: Int { activeFilterChipsData.count }

    private var activeFilterChipsData: [(label: String, clear: () -> Void)] {
        var chips: [(label: String, clear: () -> Void)] = []
        if !viewModel.cancelFromDate.isEmpty {
            chips.append((label: "From: \(viewModel.cancelFromDate)", clear: { viewModel.cancelFromDate = RefundViewModel.oneMonthAgo() }))
        }
        if !viewModel.cancelToDate.isEmpty {
            chips.append((label: "To: \(viewModel.cancelToDate)", clear: { viewModel.cancelToDate = "" }))
        }
        if !viewModel.refundFromDate.isEmpty {
            chips.append((label: "Rfnd From: \(viewModel.refundFromDate)", clear: { viewModel.refundFromDate = "" }))
        }
        if !viewModel.refundToDate.isEmpty {
            chips.append((label: "Rfnd To: \(viewModel.refundToDate)", clear: { viewModel.refundToDate = "" }))
        }
        if !viewModel.pnr.isEmpty {
            chips.append((label: "PNR: \(viewModel.pnr)", clear: { viewModel.pnr = "" }))
        }
        if !viewModel.policyNo.isEmpty {
            chips.append((label: "Policy: \(viewModel.policyNo)", clear: { viewModel.policyNo = "" }))
        }
        if !viewModel.bookingId.isEmpty {
            chips.append((label: "Booking: \(viewModel.bookingId)", clear: { viewModel.bookingId = "" }))
        }
        if !viewModel.refundStatus.isEmpty {
            let lbl = viewModel.selectedTab.refundStatusLabel(for: viewModel.refundStatus)
            chips.append((label: "Status: \(lbl)", clear: { viewModel.refundStatus = "" }))
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
                        cancelFromDateObj = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
                        cancelToDateObj   = Date()
                        refundFromDateObj = Date()
                        refundToDateObj   = Date()
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

    private var filterSheetHeight: CGFloat {
        let navBar: CGFloat = 44
        let pads: CGFloat = 16        // top + bottom content padding
        let fieldH: CGFloat = 74      // one row (date HStack or text/dropdown field)
        let spacing: CGFloat = 8      // VStack inter-item spacing
        let buttonArea: CGFloat = 80  // apply button + safeArea inset
        let buffer: CGFloat = 24

        var itemCount = 3             // 2 date rows + Booking ID always present
        if viewModel.hasPNRField    { itemCount += 1 }
        if viewModel.hasPolicyField { itemCount += 1 }
        if viewModel.hasStatusField { itemCount += 1 }

        let formH = CGFloat(itemCount) * fieldH + CGFloat(itemCount - 1) * spacing
        return navBar + pads + formH + buttonArea + buffer
    }

    private var filterSheet: some View {
        NavigationStack {
            ScrollView {
                filterForm
                    .padding(.top, DesignTokens.Spacing.sm)
                    .padding(.bottom, DesignTokens.Spacing.sm)
            }
            .clipped()
            .background(Color.ftdInputBackground)
            .safeAreaInset(edge: .bottom) {
                FTDPrimaryButton(title: viewModel.isLoading ? "Loading…" : "Apply Filters") {
                    Task {
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
                        cancelFromDateObj = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
                        cancelToDateObj   = Date()
                        refundFromDateObj = Date()
                        refundToDateObj   = Date()
                    }
                    .foregroundStyle(Color.ftdDestructiveRed)
                }
            }
        }
        .presentationDetents([.height(filterSheetHeight)])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Filter Form

    private var filterForm: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            HStack(spacing: DesignTokens.Spacing.md) {
                dateField("Cancel From", value: viewModel.cancelFromDate) { showCancelFromPicker = true }
                dateField("Cancel To",   value: viewModel.cancelToDate)   { showCancelToPicker = true }
            }
            HStack(spacing: DesignTokens.Spacing.md) {
                dateField("Refund From", value: viewModel.refundFromDate) { showRefundFromPicker = true }
                dateField("Refund To",   value: viewModel.refundToDate)   { showRefundToPicker = true }
            }
            if viewModel.hasPNRField {
                FTDTextField(label: "PNR", placeholder: "PNR", text: $viewModel.pnr, autocapitalization: .characters)
            }
            if viewModel.hasPolicyField {
                FTDTextField(label: "Policy No", placeholder: "Policy No", text: $viewModel.policyNo)
            }
            FTDTextField(label: "Booking Id", placeholder: "Booking Id", text: $viewModel.bookingId)
            if viewModel.hasStatusField {
                FTDDropdownField(
                    label: "Refund Status",
                    placeholder: "Select Status",
                    selection: $viewModel.refundStatus,
                    options: viewModel.selectedTab.refundStatusOptions,
                    optionLabel: { viewModel.selectedTab.refundStatusLabel(for: $0) }
                )
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .sheet(isPresented: $showCancelFromPicker) {
            datePickerSheet("Cancel From Date", date: $cancelFromDateObj) {
                viewModel.cancelFromDate = Self.apiFmt.string(from: cancelFromDateObj)
                showCancelFromPicker = false
            }
        }
        .sheet(isPresented: $showCancelToPicker) {
            datePickerSheet("Cancel To Date", date: $cancelToDateObj) {
                viewModel.cancelToDate = Self.apiFmt.string(from: cancelToDateObj)
                showCancelToPicker = false
            }
        }
        .sheet(isPresented: $showRefundFromPicker) {
            datePickerSheet("Refund From Date", date: $refundFromDateObj) {
                viewModel.refundFromDate = Self.apiFmt.string(from: refundFromDateObj)
                showRefundFromPicker = false
            }
        }
        .sheet(isPresented: $showRefundToPicker) {
            datePickerSheet("Refund To Date", date: $refundToDateObj) {
                viewModel.refundToDate = Self.apiFmt.string(from: refundToDateObj)
                showRefundToPicker = false
            }
        }
    }
        

    // MARK: - Date Field Helpers

    private func dateField(_ label: String, value: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                Text(label)
                    .font(.ftdPlaceholder)
                    .foregroundStyle(Color.ftdTextTertiary)
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

    private func datePickerSheet(_ title: String, date: Binding<Date>, onDone: @escaping () -> Void) -> some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Text(title)
                .font(.headline).fontWeight(.bold)
                .foregroundStyle(Color.ftdTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.lg)
            DatePicker("", selection: date, in: ...Date(), displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Color.ftdAccentOrange)
                .labelsHidden()
                .padding(.horizontal, DesignTokens.Spacing.lg)
            FTDPrimaryButton(title: "Done") { onDone() }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.lg)
        }
        .presentationDetents([.fraction(0.78)])
        .presentationDragIndicator(.visible)
        .presentationBackground(Color.ftdCardBackground)
    }

    // MARK: - Content Section

    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isLoading {
            loadingView
                .transition(.opacity)
        } else if let msg = viewModel.error {
            errorView(msg)
                .transition(.opacity)
        } else if !viewModel.hasSearched {
            emptySearchPrompt
                .transition(.opacity)
        } else if viewModel.filteredRecords.isEmpty {
            emptyResultsView
                .transition(.opacity)
        } else {
            LazyVStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(viewModel.filteredRecords) { record in
                    refundRow(record)
                }
            }
            .transition(.opacity)
            .padding(.top, DesignTokens.Spacing.sm)

            paginationRow
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.md)
                .padding(.bottom, DesignTokens.Spacing.xxl)
        }
    }

    // MARK: - Refund List Row

    private func refundRow(_ record: RefundRecord) -> some View {
        let isRefunded  = record.status?.lowercased() == "refunded"
        // To allow "Under Process" to expand too, change the line below to:
        // let canExpand = isRefunded || record.status?.lowercased() == "under process"
        let canExpand   = isRefunded
        let isExpanded  = expandedIds.contains(record.id)
        let passengerName = record.passengerName ?? record.passengers.first?.name
        let cancelType = record.passengers.first?.cancelType ?? record.fareType
        let hideOnExpand = viewModel.selectedTab == .flight || viewModel.selectedTab == .bus || viewModel.selectedTab == .cab
                        || viewModel.selectedTab == .hotel || viewModel.selectedTab == .insurance
                        || viewModel.selectedTab == .esim  || viewModel.selectedTab == .visa

        return VStack(alignment: .leading, spacing: 0) {

            // Collapsed content — hidden on expand for Flight/Bus; all other tabs keep it visible
            if !(isExpanded && canExpand && hideOnExpand) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    // Row 1: booking ref + status badge
                    HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                        Text(record.bookingRef)
                            .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                        Spacer()
                        if let status = record.status {
                            Text(status)
                                .font(.system(size: 10, weight: .semibold))
                                .foregroundStyle(statusColor(status))
                                .padding(.horizontal, DesignTokens.Spacing.sm).padding(.vertical, 3)
                                .background(statusColor(status).opacity(0.12)).clipShape(Capsule())
                        }
                    }
                    // Row 2: passenger name (left) | cancel type (right)
                    if passengerName != nil || cancelType != nil {
                        HStack(spacing: DesignTokens.Spacing.xs) {
                            if let name = passengerName {
                                Text(name).font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary).lineLimit(1)
                            }
                            Spacer()
                            if let ct = cancelType {
                                Text(ct).font(.ftdBodySM).foregroundStyle(Color.ftdTextTertiary).lineLimit(1)
                            }
                        }
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.md)
                .padding(.bottom, DesignTokens.Spacing.sm)

                Divider()

                HStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 2) {
                        if isRefunded, let amt = record.amount {
                            Text("Amount").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                            Text("₹\(amt)")
                                .font(.ftdLabelMD).foregroundStyle(Color.ftdCreditGreen).lineLimit(1)
                        } else {
                            Text(record.pnr != nil ? "PNR" : record.policyNo != nil ? "Policy" : "Ref")
                                .font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                            Text(record.pnr ?? record.policyNo ?? record.secondaryRef ?? "—")
                                .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    Rectangle().fill(Color.ftdDivider).frame(width: 1, height: 36)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cancelled").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                        Text(record.cancellationDate ?? "—")
                            .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, DesignTokens.Spacing.md)

                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.sm)
            } // end collapsed content

            // Expanded detail
            if isExpanded && canExpand {
                Divider()
                expandedDetail(record)
            }
        }
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .stroke(canExpand && isExpanded ? Color.ftdAccentOrange.opacity(0.4) : Color.ftdBorder, lineWidth: 1)
        )
        .padding(.horizontal, DesignTokens.Spacing.md)
        .contentShape(Rectangle())
        .onTapGesture {
            guard canExpand else { return }
            withAnimation(.easeInOut(duration: 0.25)) {
                if isExpanded { expandedIds.remove(record.id) }
                else          { expandedIds.insert(record.id) }
            }
        }
    }

    // MARK: - Expanded Detail Card

    @ViewBuilder
    private func expandedDetail(_ record: RefundRecord) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            let closeAction = { withAnimation(.easeInOut(duration: 0.25)) { _ = expandedIds.remove(record.id) } }

            if viewModel.selectedTab == .bus {
                busDetailCard(record, onClose: closeAction)
            } else if viewModel.selectedTab == .cab {
                cabDetailCard(record, onClose: closeAction)
            } else if viewModel.selectedTab == .hotel {
                hotelDetailCard(record, onClose: closeAction)
            } else if viewModel.selectedTab == .insurance {
                insuranceDetailCard(record, onClose: closeAction)
            } else if viewModel.selectedTab == .esim {
                esimDetailCard(record, onClose: closeAction)
            } else if viewModel.selectedTab == .visa {
                visaDetailCard(record, onClose: closeAction)
            } else if let firstPax = record.passengers.first {
                let allNames = record.passengers.count > 1
                    ? record.passengers.compactMap { $0.name?.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
                    : nil
                passengerDetailSection(firstPax, record: record, onClose: closeAction, allNames: allNames)
            } else {
                recordLevelFinancials(record, onClose: closeAction)
            }
        }
    }

    private func busDetailCard(_ record: RefundRecord, onClose: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {

            // Booking ref + status badge + X close
            HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                Text(record.bookingRef)
                    .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                Spacer()
                if let status = record.status {
                    Text(status)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(statusColor(status))
                        .padding(.horizontal, DesignTokens.Spacing.sm).padding(.vertical, 3)
                        .background(statusColor(status).opacity(0.12)).clipShape(Capsule())
                }
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.ftdTextSecondary)
                        .frame(width: 26, height: 26)
                        .background(Color.ftdInputBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            // Passenger names in 2-column grid + PNR
            let paxNames = record.passengers
                .compactMap { $0.name?.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            if !paxNames.isEmpty {
                let pairs = stride(from: 0, to: paxNames.count, by: 2)
                    .map { Array(paxNames[$0..<min($0 + 2, paxNames.count)]) }
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    ForEach(Array(pairs.enumerated()), id: \.offset) { _, pair in
                        HStack(spacing: 0) {
                            Text(pair[0])
                                .font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            if pair.count > 1 {
                                Text(pair[1])
                                    .font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                    }
                }
            }
            if let ref = record.pnr ?? record.secondaryRef {
                cardDetailRow(label: "PNR", value: ref)
            }

            Divider()

            // Left: Refund Amt + Refund Date  |  Right: Cancelled + Agent Net
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    if let amt = record.amount {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Refund Amt").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                            Text("₹\(amt)").font(.ftdLabelMD).foregroundStyle(Color.ftdCreditGreen).lineLimit(1)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Refund Date").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                        Text(record.refundDate ?? "—")
                            .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1).minimumScaleFactor(0.8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle().fill(Color.ftdDivider).frame(width: 1).padding(.vertical, 2)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cancelled").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                        Text(record.cancellationDate ?? "—")
                            .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1).minimumScaleFactor(0.8)
                    }
                    if let net = record.agentNet {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Agent Net").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                            Text("₹\(net)").font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, DesignTokens.Spacing.md)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    private func cabDetailCard(_ record: RefundRecord, onClose: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {

            // Booking ref + status badge + X close
            HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                Text(record.bookingRef)
                    .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                Spacer()
                if let status = record.status {
                    Text(status)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(statusColor(status))
                        .padding(.horizontal, DesignTokens.Spacing.sm).padding(.vertical, 3)
                        .background(statusColor(status).opacity(0.12)).clipShape(Capsule())
                }
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.ftdTextSecondary)
                        .frame(width: 26, height: 26)
                        .background(Color.ftdInputBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            // User name + Booking ID
            if let name = record.passengerName {
                Text(name).font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary).lineLimit(1)
            }
            if let ref = record.pnr ?? record.secondaryRef {
                cardDetailRow(label: "PNR", value: ref)
            }

            Divider()

            // Left: Refund Amt + Refund Date  |  Right: Cancelled + Agent Net
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    if let amt = record.amount {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Refund Amt").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                            Text("₹\(amt)").font(.ftdLabelMD).foregroundStyle(Color.ftdCreditGreen).lineLimit(1)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Refund Date").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                        Text(record.refundDate ?? "—")
                            .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1).minimumScaleFactor(0.8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle().fill(Color.ftdDivider).frame(width: 1).padding(.vertical, 2)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cancelled").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                        Text(record.cancellationDate ?? "—")
                            .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1).minimumScaleFactor(0.8)
                    }
                    if let net = record.agentNet {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Agent Net").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                            Text("₹\(net)").font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, DesignTokens.Spacing.md)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    private func hotelDetailCard(_ record: RefundRecord, onClose: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {

            // Booking ref + status badge + X close
            HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                Text(record.bookingRef)
                    .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                Spacer()
                if let status = record.status {
                    Text(status)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(statusColor(status))
                        .padding(.horizontal, DesignTokens.Spacing.sm).padding(.vertical, 3)
                        .background(statusColor(status).opacity(0.12)).clipShape(Capsule())
                }
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.ftdTextSecondary)
                        .frame(width: 26, height: 26)
                        .background(Color.ftdInputBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            // Passenger names in left-right grid
            let paxNames = record.passengers
                .compactMap { $0.name?.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            if !paxNames.isEmpty {
                let pairs = stride(from: 0, to: paxNames.count, by: 2).map {
                    Array(paxNames[$0..<min($0 + 2, paxNames.count)])
                }
                ForEach(Array(pairs.enumerated()), id: \.offset) { _, pair in
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text(pair[0])
                            .font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if pair.count > 1 {
                            Text(pair[1])
                                .font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }

            // PNR (bookingId)
            if let ref = record.pnr ?? record.secondaryRef {
                cardDetailRow(label: "PNR", value: ref)
            }

            Divider()

            // Left: Refund Amt + Refund Date  |  Right: Cancelled + Agent Net
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    if let amt = record.amount {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Refund Amt").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                            Text("₹\(amt)").font(.ftdLabelMD).foregroundStyle(Color.ftdCreditGreen).lineLimit(1)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Refund Date").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                        Text(record.refundDate ?? "—")
                            .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1).minimumScaleFactor(0.8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle().fill(Color.ftdDivider).frame(width: 1).padding(.vertical, 2)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cancelled").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                        Text(record.cancellationDate ?? "—")
                            .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1).minimumScaleFactor(0.8)
                    }
                    if let net = record.agentNet {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Agent Net").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                            Text("₹\(net)").font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, DesignTokens.Spacing.md)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    private func insuranceDetailCard(_ record: RefundRecord, onClose: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {

            HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                Text(record.bookingRef)
                    .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                Spacer()
                if let status = record.status {
                    Text(status)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(statusColor(status))
                        .padding(.horizontal, DesignTokens.Spacing.sm).padding(.vertical, 3)
                        .background(statusColor(status).opacity(0.12)).clipShape(Capsule())
                }
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.ftdTextSecondary)
                        .frame(width: 26, height: 26)
                        .background(Color.ftdInputBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            if !record.passengerNames.isEmpty {
                let pairs = stride(from: 0, to: record.passengerNames.count, by: 2).map {
                    Array(record.passengerNames[$0..<min($0 + 2, record.passengerNames.count)])
                }
                ForEach(Array(pairs.enumerated()), id: \.offset) { _, pair in
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text(pair[0])
                            .font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary)
                            .lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                        if pair.count > 1 {
                            Text(pair[1])
                                .font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary)
                                .lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }

            if let policy = record.policyNo {
                cardDetailRow(label: "Policy No", value: policy)
            }

            Divider()

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    if let amt = record.amount {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Refund Amt").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                            Text("₹\(amt)").font(.ftdLabelMD).foregroundStyle(Color.ftdCreditGreen).lineLimit(1)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Refund Date").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                        Text(record.refundDate ?? "—")
                            .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1).minimumScaleFactor(0.8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle().fill(Color.ftdDivider).frame(width: 1).padding(.vertical, 2)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cancelled").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                        Text(record.cancellationDate ?? "—")
                            .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1).minimumScaleFactor(0.8)
                    }
                    if let net = record.agentNet {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Agent Net").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                            Text("₹\(net)").font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, DesignTokens.Spacing.md)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    private func esimDetailCard(_ record: RefundRecord, onClose: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {

            HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                Text(record.bookingRef)
                    .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                Spacer()
                if let status = record.status {
                    Text(status)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(statusColor(status))
                        .padding(.horizontal, DesignTokens.Spacing.sm).padding(.vertical, 3)
                        .background(statusColor(status).opacity(0.12)).clipShape(Capsule())
                }
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.ftdTextSecondary)
                        .frame(width: 26, height: 26)
                        .background(Color.ftdInputBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            if !record.passengerNames.isEmpty {
                let pairs = stride(from: 0, to: record.passengerNames.count, by: 2).map {
                    Array(record.passengerNames[$0..<min($0 + 2, record.passengerNames.count)])
                }
                ForEach(Array(pairs.enumerated()), id: \.offset) { _, pair in
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text(pair[0])
                            .font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary)
                            .lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                        if pair.count > 1 {
                            Text(pair[1])
                                .font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary)
                                .lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    if let amt = record.amount {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Refund Amt").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                            Text("₹\(amt)").font(.ftdLabelMD).foregroundStyle(Color.ftdCreditGreen).lineLimit(1)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Refund Date").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                        Text(record.refundDate ?? "—")
                            .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1).minimumScaleFactor(0.8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle().fill(Color.ftdDivider).frame(width: 1).padding(.vertical, 2)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cancelled").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                        Text(record.cancellationDate ?? "—")
                            .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1).minimumScaleFactor(0.8)
                    }
                    if let net = record.agentNet {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Agent Net").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                            Text("₹\(net)").font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, DesignTokens.Spacing.md)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    private func visaDetailCard(_ record: RefundRecord, onClose: @escaping () -> Void) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {

            HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                Text(record.bookingRef)
                    .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                Spacer()
                if let status = record.status {
                    Text(status)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(statusColor(status))
                        .padding(.horizontal, DesignTokens.Spacing.sm).padding(.vertical, 3)
                        .background(statusColor(status).opacity(0.12)).clipShape(Capsule())
                }
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(Color.ftdTextSecondary)
                        .frame(width: 26, height: 26)
                        .background(Color.ftdInputBackground)
                        .clipShape(Circle())
                }
                .buttonStyle(.plain)
            }

            if !record.passengerNames.isEmpty {
                let pairs = stride(from: 0, to: record.passengerNames.count, by: 2).map {
                    Array(record.passengerNames[$0..<min($0 + 2, record.passengerNames.count)])
                }
                ForEach(Array(pairs.enumerated()), id: \.offset) { _, pair in
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text(pair[0])
                            .font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary)
                            .lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                        if pair.count > 1 {
                            Text(pair[1])
                                .font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary)
                                .lineLimit(1).frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            }

            Divider()

            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    if let amt = record.amount {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Refund Amt").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                            Text("₹\(amt)").font(.ftdLabelMD).foregroundStyle(Color.ftdCreditGreen).lineLimit(1)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Refund Date").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                        Text(record.refundDate ?? "—")
                            .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1).minimumScaleFactor(0.8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle().fill(Color.ftdDivider).frame(width: 1).padding(.vertical, 2)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Cancelled").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                        Text(record.cancellationDate ?? "—")
                            .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1).minimumScaleFactor(0.8)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, DesignTokens.Spacing.md)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    @ViewBuilder
    private func passengerDetailSection(_ pax: RefundPassenger, record: RefundRecord, onClose: (() -> Void)? = nil, allNames: [String]? = nil) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {

            if let names = allNames, !names.isEmpty {
                // Multi-passenger: top row with status badge + close, then names in left-right grid
                HStack(alignment: .center, spacing: DesignTokens.Spacing.sm) {
                    if let r = pax.refunded {
                        let isRef = r == 1
                        Text(isRef ? "Refunded" : "Pending")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(isRef ? Color.ftdCreditGreen : Color.ftdAccentOrange)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(isRef ? Color.ftdCreditGreen.opacity(0.1) : Color.ftdAccentOrange.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    Spacer()
                    if let close = onClose {
                        Button(action: close) {
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.ftdTextSecondary)
                                .frame(width: 26, height: 26)
                                .background(Color.ftdInputBackground)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
                let pairs = stride(from: 0, to: names.count, by: 2).map {
                    Array(names[$0..<min($0 + 2, names.count)])
                }
                ForEach(Array(pairs.enumerated()), id: \.offset) { _, pair in
                    HStack(spacing: DesignTokens.Spacing.sm) {
                        Text(pair[0])
                            .font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if pair.count > 1 {
                            Text(pair[1])
                                .font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary)
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            } else {
                // Single passenger: name + pax type + refund status + close
                HStack(spacing: DesignTokens.Spacing.xs) {
                    Text(pax.name ?? "Passenger")
                        .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary).lineLimit(1)
                    if let pt = pax.paxType {
                        Text(pt)
                            .font(.system(size: 10, weight: .semibold)).foregroundStyle(Color.ftdAccentOrange)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(Color.ftdAccentOrange.opacity(0.1)).clipShape(Capsule())
                    }
                    if let r = pax.refunded {
                        let isRef = r == 1
                        Text(isRef ? "Refunded" : "Pending")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(isRef ? Color.ftdCreditGreen : Color.ftdAccentOrange)
                            .padding(.horizontal, 6).padding(.vertical, 2)
                            .background(isRef ? Color.ftdCreditGreen.opacity(0.1) : Color.ftdAccentOrange.opacity(0.1))
                            .clipShape(Capsule())
                    }
                    Spacer()
                    if let close = onClose {
                        Button(action: close) {
                            Image(systemName: "xmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(Color.ftdTextSecondary)
                                .frame(width: 26, height: 26)
                                .background(Color.ftdInputBackground)
                                .clipShape(Circle())
                        }
                        .buttonStyle(.plain)
                    }
                }
            }

            // Unique Ref No + FCID — grouped tightly
            let refId = record.bookingRef.isEmpty ? pax.ticketNo : record.bookingRef
            let fcidValue = pax.fcid.flatMap { $0.isEmpty ? nil : $0 }
            if refId != nil || fcidValue != nil {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    if let id = refId {
                        Text(id).font(.ftdLabelXS).foregroundStyle(Color.ftdTextSecondary)
                    }
                    if let fcid = fcidValue {
                        Text("\(fcid)\(pax.cancelType.map { " (\($0))" } ?? "")")
                            .font(.ftdLabelXS).foregroundStyle(Color.ftdTextSecondary)
                    }
                }
                .padding(.top, DesignTokens.Spacing.xs)
            }

            // Amount | Cancelled two-column strip
            // For bookings without per-passenger refund (e.g. bus), fall back to record-level amount on the first passenger card
            let displayAmt = pax.refund ?? (onClose != nil ? record.amount : nil)
            HStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Amount").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                    Text(displayAmt.map { "₹\($0)" } ?? "—")
                        .font(.ftdLabelMD).foregroundStyle(Color.ftdCreditGreen).lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Rectangle().fill(Color.ftdDivider).frame(width: 1, height: 36)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Cancelled").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                    Text(pax.cancelDate ?? record.cancellationDate ?? "—")
                        .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary)
                        .minimumScaleFactor(0.8).lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, DesignTokens.Spacing.md)
            }

            // Route: Carrier · FareType · PNR (PNR uses smaller medium font)
            let mainRouteParts = [record.carrierName, record.fareType].compactMap { $0 }
            let pnrValue = pax.pnr ?? record.pnr
            if !mainRouteParts.isEmpty, let pnr = pnrValue {
                (Text(mainRouteParts.joined(separator: " · "))
                    .font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary)
                + Text(" · \(pnr)")
                    .font(.ftdLabelXS).foregroundStyle(Color.ftdTextSecondary))
            } else if !mainRouteParts.isEmpty {
                Text(mainRouteParts.joined(separator: " · "))
                    .font(.ftdBodySM).foregroundStyle(Color.ftdTextSecondary)
            } else if let pnr = pnrValue {
                Text(pnr).font(.ftdLabelXS).foregroundStyle(Color.ftdTextSecondary)
            }

            // Agent Net | Airline Charge | FTD Fees
            let agentNet      = record.agentNet ?? pax.ancillaryRefund?.agentNet
            let airlineCharge = pax.ancillaryRefund?.airlineCharge
            let ftdFees       = pax.ancillaryRefund?.ftdFees
            if agentNet != nil || airlineCharge != nil || ftdFees != nil {
                HStack(spacing: 0) {
                    if let v = agentNet      { detailFinancialCell("Agent Net",      v) }
                    if let v = airlineCharge { detailFinancialCell("Airline Charge", v) }
                    if let v = ftdFees       { detailFinancialCell("FTD Fees",       v) }
                }
            }

            if let anc = pax.ancillaryRefund {
                // Breakup: refund movement amounts
                if let amounts = anc.refundAmounts, !amounts.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                        Text("Breakup")
                            .font(.ftdLabelXS).fontWeight(.semibold).foregroundStyle(Color.ftdTextTertiary)
                        ForEach(Array(amounts.enumerated()), id: \.offset) { i, amt in
                            HStack {
                                Text(amounts.count == 1 ? "Refund Amount" : "Refund Amount \(i + 1)")
                                    .font(.ftdLabelXS).foregroundStyle(Color.ftdTextSecondary)
                                Spacer()
                                Text(amt >= 0 ? "₹\(Int(amt))" : "-₹\(Int(abs(amt)))")
                                    .font(.ftdLabelXS).fontWeight(.semibold)
                                    .foregroundStyle(amt >= 0 ? Color.ftdCreditGreen : Color.ftdDestructiveRed)
                            }
                        }
                    }
                }

                // Service table
                let hasServices = anc.seat != nil || anc.meal != nil || anc.baggage != nil
                               || anc.specialService != nil || anc.webCheckin != nil
                if hasServices {
                    Divider()
                    VStack(spacing: DesignTokens.Spacing.xxs) {
                        HStack(spacing: 0) {
                            Text("Service").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary).frame(maxWidth: .infinity, alignment: .leading)
                            Text("Paid").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary).frame(width: 56, alignment: .trailing)
                            Text("Refund").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary).frame(width: 56, alignment: .trailing)
                        }
                        Divider()
                        if let s = anc.seat            { ancillaryServiceRow("Seat",            s) }
                        if let s = anc.meal            { ancillaryServiceRow("Meal",            s) }
                        if let s = anc.baggage         { ancillaryServiceRow("Baggage",         s) }
                        if let s = anc.specialService  { ancillaryServiceRow("Special",         s) }
                        if let s = anc.webCheckin      { ancillaryServiceRow("Web Check-in",    s) }
                    }
                }
            }

            // Transactions
            if let refs = pax.referenceId, !refs.isEmpty {
                Divider()
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    Text("Transactions")
                        .font(.ftdLabelXS).fontWeight(.semibold).foregroundStyle(Color.ftdTextTertiary)
                    ForEach(Array(refs.enumerated()), id: \.offset) { i, ref in
                        HStack {
                            Text(ref)
                                .font(.system(size: 10)).foregroundStyle(Color.ftdTextPrimary)
                                .lineLimit(1).minimumScaleFactor(0.75)
                            Spacer()
                            if let dates = pax.valueDate, i < dates.count {
                                Text(dates[i]).font(.system(size: 10)).foregroundStyle(Color.ftdTextSecondary).lineLimit(1)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    private func recordLevelFinancials(_ record: RefundRecord, onClose: (() -> Void)? = nil) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            if let close = onClose {
                HStack {
                    Spacer()
                    Button(action: close) {
                        Image(systemName: "xmark")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(Color.ftdTextSecondary)
                            .frame(width: 26, height: 26)
                            .background(Color.ftdInputBackground)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
            if let name = record.passengerName {
                cardDetailRow(label: "Passenger", value: name)
            }
            if let pnr = record.pnr {
                cardDetailRow(label: "PNR", value: pnr)
            }
            if let cd = record.cancellationDate {
                cardDetailRow(label: "Cancelled", value: cd)
            }
            if let rd = record.refundDate {
                cardDetailRow(label: "Refund Date", value: rd)
            }
            HStack(spacing: 0) {
                if let net = record.agentNet {
                    detailFinancialCell("Agent Net", net)
                }
                if let amt = record.amount {
                    detailFinancialCell("Refund Amt", amt, valueColor: Color.ftdCreditGreen)
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
    }

    private func detailFinancialCell(_ label: String, _ value: String, valueColor: Color = Color.ftdTextPrimary) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
            Text("₹\(value)").font(.ftdLabelMD).foregroundStyle(valueColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func cardDetailRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Text(label)
                .font(.ftdLabelXS)
                .foregroundStyle(Color.ftdTextTertiary)
                .frame(width: 84, alignment: .leading)
            Text(value)
                .font(.ftdLabelMD)
                .foregroundStyle(Color.ftdTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func passengerBlock(_ pax: RefundPassenger, index: Int, showIndex: Bool) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            HStack(spacing: DesignTokens.Spacing.xs) {
                if showIndex {
                    Text("Pax \(index)")
                        .font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
                }
                Text(pax.name ?? "Passenger \(index)")
                    .font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary)
                if let pt = pax.paxType {
                    Text(pt)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.ftdAccentOrange)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(Color.ftdAccentOrange.opacity(0.1))
                        .clipShape(Capsule())
                }
                if let r = pax.refunded {
                    let isRefunded = r == 1
                    Text(isRefunded ? "Refunded" : "Pending")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(isRefunded ? Color.ftdCreditGreen : Color.ftdAccentOrange)
                        .padding(.horizontal, 6).padding(.vertical, 2)
                        .background(isRefunded ? Color.ftdCreditGreen.opacity(0.1) : Color.ftdAccentOrange.opacity(0.1))
                        .clipShape(Capsule())
                }
                Spacer()
            }

            if let pnr = pax.pnr {
                if pnr == pax.ticketNo {
                    cardDetailRow(label: "PNR / Ticket", value: pnr)
                } else {
                    cardDetailRow(label: "PNR", value: pnr)
                    if let tn = pax.ticketNo { cardDetailRow(label: "Ticket No", value: tn) }
                }
            } else if let tn = pax.ticketNo {
                cardDetailRow(label: "Ticket No", value: tn)
            }

            if let bid = pax.bookingId  { cardDetailRow(label: "Booking ID",  value: bid) }
            if let cd  = pax.cancelDate { cardDetailRow(label: "Cancelled",   value: cd) }
            if let rd  = pax.refundDate { cardDetailRow(label: "Refund Date", value: rd) }
            if let ct  = pax.cancelType { cardDetailRow(label: "Cancel Type", value: ct) }
            if let fcid = pax.fcid, !fcid.isEmpty { cardDetailRow(label: "FCID", value: fcid) }
            if let r = pax.refund, let val = Double(r), val > 0 {
                cardDetailRow(label: "Refund Amt", value: "₹\(r)")
            }
            if let refs = pax.referenceId, !refs.isEmpty {
                transactionHistoryBlock(refs: refs, dates: pax.valueDate)
            }
            if let anc = pax.ancillaryRefund {
                ancillaryBlock(anc)
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .background(Color.ftdInputBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
    }

    @ViewBuilder
    private func ancillaryBlock(_ anc: RefundAncillaryDetail) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Ancillary Breakdown")
                .font(.ftdLabelXS).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextTertiary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                      spacing: DesignTokens.Spacing.xs) {
                if let v = anc.airlineCharge { ancillaryStatCell(label: "Airline Charge", value: v) }
                if let v = anc.ftdFees       { ancillaryStatCell(label: "FTD Fees",       value: v) }
                if let v = anc.agentNet      { ancillaryStatCell(label: "Agent Net",       value: v) }
                if let v = anc.refundAmt     { ancillaryStatCell(label: "Refund Amt",      value: v) }
            }

            let hasServices = anc.seat != nil || anc.meal != nil || anc.baggage != nil
                           || anc.specialService != nil || anc.webCheckin != nil
            if hasServices {
                VStack(spacing: DesignTokens.Spacing.xxs) {
                    HStack(spacing: 0) {
                        Text("Service").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary).frame(maxWidth: .infinity, alignment: .leading)
                        Text("Paid").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary).frame(width: 56, alignment: .trailing)
                        Text("Refund").font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary).frame(width: 56, alignment: .trailing)
                    }
                    Divider()
                    if let s = anc.seat            { ancillaryServiceRow("Seat",            s) }
                    if let s = anc.meal            { ancillaryServiceRow("Meal",            s) }
                    if let s = anc.baggage         { ancillaryServiceRow("Baggage",         s) }
                    if let s = anc.specialService  { ancillaryServiceRow("Special Service", s) }
                    if let s = anc.webCheckin      { ancillaryServiceRow("Web Check-in",    s) }
                }
            }

            if let amounts = anc.refundAmounts, !amounts.isEmpty {
                refundMovementsBlock(amounts)
            }
        }
        .padding(DesignTokens.Spacing.sm)
        .background(Color.ftdAccentOrange.opacity(0.04))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
    }

    private func ancillaryStatCell(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.ftdLabelXS).foregroundStyle(Color.ftdTextTertiary)
            Text("₹\(value)").font(.ftdLabelMD).foregroundStyle(Color.ftdTextPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func ancillaryServiceRow(_ name: String, _ svc: RefundAncillaryService) -> some View {
        HStack(spacing: 0) {
            Text(name).font(.ftdLabelXS).foregroundStyle(Color.ftdTextSecondary).frame(maxWidth: .infinity, alignment: .leading)
            Text("₹\(svc.paid ?? "0")").font(.ftdLabelXS).foregroundStyle(Color.ftdTextPrimary).frame(width: 56, alignment: .trailing)
            Text("₹\(svc.refund ?? "0")").font(.ftdLabelXS).foregroundStyle(Color.ftdCreditGreen).frame(width: 56, alignment: .trailing)
        }
    }

    private func transactionHistoryBlock(refs: [String], dates: [String]?) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text("Transactions")
                .font(.ftdLabelXS).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextTertiary)
            ForEach(Array(refs.enumerated()), id: \.offset) { idx, ref in
                HStack(spacing: 4) {
                    Text(ref)
                        .font(.system(size: 10))
                        .foregroundStyle(Color.ftdTextPrimary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    Spacer()
                    if let dt = dates, idx < dt.count {
                        Text(dt[idx])
                            .font(.system(size: 10))
                            .foregroundStyle(Color.ftdTextSecondary)
                            .lineLimit(1)
                    }
                }
            }
        }
    }

    private func refundMovementsBlock(_ amounts: [Double]) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Text("Refund Movements")
                .font(.ftdLabelXS).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextTertiary)
            ForEach(Array(amounts.enumerated()), id: \.offset) { idx, amt in
                HStack {
                    Text("Movement \(idx + 1)")
                        .font(.ftdLabelXS)
                        .foregroundStyle(Color.ftdTextSecondary)
                    Spacer()
                    let isCredit = amt >= 0
                    Text(isCredit ? "₹\(Int(amt))" : "-₹\(Int(abs(amt)))")
                        .font(.ftdLabelXS).fontWeight(.semibold)
                        .foregroundStyle(isCredit ? Color.ftdCreditGreen : Color.ftdDestructiveRed)
                }
            }
        }
    }

    private func statusColor(_ status: String) -> Color {
        switch status.lowercased() {
        case "refunded":               return Color.ftdCreditGreen
        case "rejected", "cancelled":  return Color.ftdDestructiveRed
        case "under process":          return Color.ftdAccentOrange
        default:                       return Color.ftdAccentOrange
        }
    }

    // MARK: - Pagination

    private var paginationRow: some View {
        let count = viewModel.filteredRecords.count
        let total = viewModel.totalEntries
        let label = count == total
            ? "\(total) entries"
            : "\(count) of \(total) entries"
        return Text(label)
            .font(.ftdLabelXS)
            .foregroundStyle(Color.ftdTextSecondary)
            .frame(maxWidth: .infinity, alignment: .center)
    }

    // MARK: - State Views

    private var emptySearchPrompt: some View {
        GeometryReader { geo in
            VStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: "magnifyingglass")
                    .font(.largeTitle)
                    .foregroundStyle(Color.ftdTextSecondary.opacity(0.4))
                Text("Search for refunds")
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                Text("Tap Filters to set a date range and apply.")
                    .font(.caption)
                    .foregroundStyle(Color.ftdTextSecondary.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .frame(width: geo.size.width, height: max(geo.size.height, 400))
        }
        .frame(maxWidth: .infinity, minHeight: 400)
        .padding(DesignTokens.Spacing.lg)
    }

    private var emptyResultsView: some View {
        GeometryReader { geo in
            VStack(spacing: DesignTokens.Spacing.md) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.largeTitle)
                    .foregroundStyle(Color.ftdTextSecondary.opacity(0.4))
                Text("No refunds found")
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                Text("Try adjusting your filters.")
                    .font(.caption)
                    .foregroundStyle(Color.ftdTextSecondary.opacity(0.7))
            }
            .frame(width: geo.size.width, height: max(geo.size.height, 400))
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    private var loadingView: some View {
        GeometryReader { geo in
            VStack(spacing: DesignTokens.Spacing.md) {
                ProgressView().scaleEffect(1.2)
                    .tint(Color.ftdAccentOrange)
                Text("Loading refunds…")
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
            }
            .frame(width: geo.size.width, height: max(geo.size.height, 400))
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(Color.ftdDestructiveRed)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
                .multilineTextAlignment(.center)
            Button("Retry") { Task { await viewModel.search() } }
                .buttonStyle(.borderedProminent)
                .tint(Color.ftdAccentOrange)
        }
        .padding(DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity, minHeight: 300)
    }
}

//something went wrong, the data couldn't be read becuase it isn't corrct formate retry and cancel button upload money page load  trace looging api intgration
//Version needs to be updated if possible auto  config file and app stor and ftd side menu triangle
// two version of same app in single device
// infra lavel fix for multiple user registration.
// your paymnet was processed but confirmation failed error on why
//  review my instant money upload flow and how do i handle checkout sucess response and error response which type of error or sucess alert i amshowing and what is there message shows.
