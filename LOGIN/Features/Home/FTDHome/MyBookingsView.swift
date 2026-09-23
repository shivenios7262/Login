import SwiftUI

struct MyBookingsView: View {
    @Bindable var viewModel: BookingsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var filtersExpanded = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                tabBar
                Divider().overlay(Color.ftdBorder.opacity(0.6))
                filterToggleRow
                if filtersExpanded {
                    filterForm
                        .transition(.move(edge: .top).combined(with: .opacity))
                    Divider().overlay(Color.ftdBorder.opacity(0.4))
                }
                contentArea
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .background(Color.ftdInputBackground)
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.ftdCardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "My Bookings"))
                        .font(.ftdSectionHeaderMedium)
                        .foregroundStyle(Color.ftdTextPrimary)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color.ftdTextPrimary)
                            .frame(width: 30, height: 30)
                            .background(Color.ftdInputBackground)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .task { await viewModel.fetchBookings() }
        .onChange(of: viewModel.selectedTab) { _, _ in
            filtersExpanded = false
            Task { await viewModel.search() }
        }
    }

    // MARK: - Tab Bar

    private var tabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(BookingTab.allCases) { tab in
                    tabItem(tab)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.sm)
        }
        .background(Color.ftdCardBackground)
        .frame(height: 48)
    }

    private func tabItem(_ tab: BookingTab) -> some View {
        let isSelected = viewModel.selectedTab == tab
        return Button {
            withAnimation(.easeInOut(duration: DesignTokens.Animation.fast)) {
                viewModel.selectedTab = tab
            }
        } label: {
            VStack(spacing: 0) {
                Text(tab.rawValue)
                    .font(isSelected ? .ftdLabelSM : .ftdLabelMD)
                    .foregroundStyle(isSelected ? Color.ftdAccentOrange : Color.ftdTextSecondary)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .frame(height: 44)
                Rectangle()
                    .fill(isSelected ? Color.ftdAccentOrange : Color.clear)
                    .frame(height: 3)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: viewModel.selectedTab)
    }

    // MARK: - Filter Toggle Row

    private var filterToggleRow: some View {
        HStack {
            Button {
                withAnimation(.easeInOut(duration: DesignTokens.Animation.fast)) {
                    filtersExpanded.toggle()
                }
            } label: {
                HStack(spacing: DesignTokens.Spacing.xs) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.system(size: 15))
                    Text(String(localized: "Filters"))
                        .font(.ftdLabelMD)
                    Image(systemName: filtersExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                }
                .foregroundStyle(Color.ftdAccentOrange)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                viewModel.resetFilters()
                Task { await viewModel.search() }
            } label: {
                Text(String(localized: "Reset"))
                    .font(.ftdLabelSM)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .background(Color.ftdInputBackground)
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color.ftdBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)

            Button {
                Task { await viewModel.search() }
            } label: {
                Text(String(localized: "Search"))
                    .font(.ftdLabelSM)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.vertical, DesignTokens.Spacing.xs)
                    .background(Color.ftdAccentOrange)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(Color.ftdCardBackground)
    }

    // MARK: - Filter Form

    @ViewBuilder
    private var filterForm: some View {
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
        .background(Color.ftdCardBackground)
        .frame(maxHeight: 260)
    }

    // MARK: Filter fields per tab

    @ViewBuilder private var flightFilters: some View {
        filterField("From Date",  placeholder: "yyyy-mm-dd", text: $viewModel.flightFromDate)
        filterField("To Date",    placeholder: "yyyy-mm-dd", text: $viewModel.flightToDate)
        filterField("Airline",    placeholder: "Airline code",text: $viewModel.flightAirline)
        filterField("Status",     placeholder: "e.g. SUCCESS",text: $viewModel.flightStatus)
        filterField("PNR",        placeholder: "PNR",         text: $viewModel.flightPNR)
        filterField("First Name", placeholder: "Passenger",   text: $viewModel.flightName)
    }

    @ViewBuilder private var busFilters: some View {
        filterField("From Date",   placeholder: "yyyy-mm-dd", text: $viewModel.busFromDate)
        filterField("To Date",     placeholder: "yyyy-mm-dd", text: $viewModel.busToDate)
        filterField("Depart Date", placeholder: "yyyy-mm-dd", text: $viewModel.busDepartDate)
        filterField("Booking Date",placeholder: "yyyy-mm-dd", text: $viewModel.busBkgDate)
        filterField("Ref No",      placeholder: "Reference",  text: $viewModel.busRefNo)
        filterField("Pass Name",   placeholder: "Passenger",  text: $viewModel.busPassName)
        filterField("Status",      placeholder: "Status",     text: $viewModel.busStatus)
    }

    @ViewBuilder private var cabFilters: some View {
        filterField("From Date",   placeholder: "yyyy-mm-dd", text: $viewModel.cabFromDate)
        filterField("To Date",     placeholder: "yyyy-mm-dd", text: $viewModel.cabToDate)
        filterField("PNR",         placeholder: "PNR",        text: $viewModel.cabPNR)
        filterField("Depart Date", placeholder: "yyyy-mm-dd", text: $viewModel.cabDepartDate)
        filterField("Booking Date",placeholder: "yyyy-mm-dd", text: $viewModel.cabBkgDate)
        filterField("Status",      placeholder: "Status",     text: $viewModel.cabStatus)
        filterField("First Name",  placeholder: "Passenger",  text: $viewModel.cabName)
    }

    @ViewBuilder private var hotelFilters: some View {
        filterField("Check-In",  placeholder: "yyyy-mm-dd", text: $viewModel.hotelCheckIn)
        filterField("Check-Out", placeholder: "yyyy-mm-dd", text: $viewModel.hotelCheckOut)
        filterField("PNR",       placeholder: "PNR",        text: $viewModel.hotelPNR)
        filterField("Ref No",    placeholder: "Reference",  text: $viewModel.hotelRefNo)
        filterField("Status",    placeholder: "Status",     text: $viewModel.hotelStatus)
    }

    @ViewBuilder private var insuranceFilters: some View {
        filterField("Onward Date", placeholder: "yyyy-mm-dd",  text: $viewModel.insOnwardDate)
        filterField("Return Date", placeholder: "yyyy-mm-dd",  text: $viewModel.insReturnDate)
        filterField("Country",     placeholder: "Country name", text: $viewModel.insCountry)
        filterField("Status",      placeholder: "Status",       text: $viewModel.insStatus)
        filterField("Type",        placeholder: "Type",         text: $viewModel.insType)
        filterField("Reference",   placeholder: "Ref no",       text: $viewModel.insReference)
    }

    @ViewBuilder private var visaFilters: some View {
        filterField("Onward Date", placeholder: "yyyy-mm-dd",  text: $viewModel.visaOnwardDate)
        filterField("Return Date", placeholder: "yyyy-mm-dd",  text: $viewModel.visaReturnDate)
        filterField("Country",     placeholder: "Country name", text: $viewModel.visaCountry)
        filterField("Reference",   placeholder: "Ref no",       text: $viewModel.visaReference)
    }

    @ViewBuilder private var esimFilters: some View {
        filterField("From Date", placeholder: "yyyy-mm-dd", text: $viewModel.esimFromDate)
        filterField("To Date",   placeholder: "yyyy-mm-dd", text: $viewModel.esimToDate)
        filterField("Reference", placeholder: "Ref no",     text: $viewModel.esimReference)
    }

    private func filterField(_ label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            Text(label)
                .font(.caption2).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextSecondary)
                .textCase(.uppercase)
                .tracking(0.3)
            TextField(placeholder, text: text)
                .font(.footnote)
                .foregroundStyle(Color.ftdTextPrimary)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .padding(.horizontal, DesignTokens.Spacing.inputVertical)
                .padding(.vertical, DesignTokens.Spacing.sm)
                .background(Color.ftdInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                        .stroke(Color.ftdBorder, lineWidth: 1)
                )
        }
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
        } else if viewModel.flightBookings.isEmpty {
            emptyView
        } else {
            flightList
        }
    }

    // MARK: - Flight List

    private var flightList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: DesignTokens.Spacing.md) {
                ForEach(viewModel.flightBookings) { booking in
                    flightCard(booking)
                }
            }
            .padding(DesignTokens.Spacing.lg)
        }
    }

    // MARK: - Flight Card

    private func flightCard(_ b: AgentFlightBooking) -> some View {
        VStack(alignment: .leading, spacing: 0) {

            // ─── Route Header (dark background) ───
            HStack {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    VStack(spacing: 2) {
                        Text(b.origin ?? "-")
                            .font(.title3).fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text(b.originCity ?? "")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                    VStack(spacing: DesignTokens.Spacing.xxs) {
                        Image(systemName: "airplane")
                            .font(.system(size: 13))
                            .foregroundStyle(Color.ftdAccentOrange)
                        if let trip = b.tripType, trip.lowercased().contains("round") {
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.system(size: 9))
                                .foregroundStyle(Color.ftdAccentOrange.opacity(0.7))
                        }
                    }
                    VStack(spacing: 2) {
                        Text(b.destination ?? "-")
                            .font(.title3).fontWeight(.bold)
                            .foregroundStyle(.white)
                        Text(b.destinationCity ?? "")
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.7))
                            .lineLimit(1)
                    }
                }
                Spacer()
                statusBadge(b.status)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color(red: 0.12, green: 0.14, blue: 0.18))

            // ─── Info Grid ───
            HStack(alignment: .top, spacing: 0) {
                infoCell("Airline",  value: b.carrierName ?? b.carrier)
                infoCell("PNR",      value: b.pnr)
                infoCell("Depart",   value: fmtDate(b.departureDate))
                infoCell("Time",     value: fmtTime(b.departureTime))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, DesignTokens.Spacing.inputVertical)

            // ─── Passengers ───
            if let pax = b.passengers, !pax.isEmpty {
                Divider().padding(.horizontal, 14)
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                    Text("Passengers")
                        .font(.caption2).fontWeight(.semibold)
                        .foregroundStyle(Color.ftdTextSecondary)
                    ForEach(Array(pax.prefix(3).enumerated()), id: \.offset) { _, p in
                        HStack(spacing: 6) {
                            Image(systemName: "person.fill")
                                .font(.caption2)
                                .foregroundStyle(Color.ftdAccentOrange)
                            Text(p.fullName)
                                .font(.caption)
                                .foregroundStyle(Color.ftdTextPrimary)
                            if let t = p.passengerType {
                                Text("(\(t))").font(.caption2).foregroundStyle(Color.ftdTextSecondary)
                            }
                        }
                    }
                    if let count = b.passengers?.count, count > 3 {
                        Text("+\(count - 3) more")
                            .font(.caption2).foregroundStyle(Color.ftdTextSecondary)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, DesignTokens.Spacing.inputVertical)
            }

            Divider().padding(.horizontal, 14)

            // ─── Footer: Ref + Amounts + Actions ───
            VStack(spacing: DesignTokens.Spacing.sm) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Ref No")
                            .font(.caption2).foregroundStyle(Color.ftdTextSecondary)
                        Text(b.uniqueRefNo ?? "-")
                            .font(.caption).fontWeight(.semibold)
                            .foregroundStyle(Color.ftdAccentOrange)
                    }
                    Spacer()
                    HStack(spacing: DesignTokens.Spacing.md) {
                        if let fare = b.totalFare, !fare.isEmpty {
                            fareChip(label: "Total", value: fare, color: Color.ftdTextPrimary)
                        }
                        if let net = b.agentNetPrice, !net.isEmpty {
                            fareChip(label: "Net", value: net, color: Color.ftdAccentTeal)
                        }
                    }
                }

                // Action Buttons
                HStack(spacing: DesignTokens.Spacing.sm) {
                    actionButton("Cancel",   color: Color.ftdDestructiveRed)
                    actionButton("Reissue",  color: Color.ftdAccentOrange)
                    actionButton("Invoice",  color: Color.ftdAccentTeal)
                    Spacer()
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

    // MARK: - Card sub-components

    private func statusBadge(_ status: String?) -> some View {
        let s = status ?? "-"
        let color: Color = {
            switch s.lowercased() {
            case "success", "confirmed", "booked": return .green
            case "cancelled", "failed":            return Color.ftdDestructiveRed
            case "pending":                        return Color.ftdAccentOrange
            default:                               return Color.ftdTextSecondary
            }
        }()
        return Text(s.uppercased())
            .font(.system(size: 9, weight: .bold))
            .tracking(0.5)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .padding(.vertical, 4)
            .background(color.opacity(0.18))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }

    private func infoCell(_ title: String, value: String?) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            Text(title)
                .font(.caption2).foregroundStyle(Color.ftdTextSecondary)
            Text(value ?? "-")
                .font(.caption).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func fareChip(label: String, value: String, color: Color) -> some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text(label)
                .font(.caption2).foregroundStyle(Color.ftdTextSecondary)
            Text("₹\(value)")
                .font(.caption).fontWeight(.bold)
                .foregroundStyle(color)
        }
    }

    private func actionButton(_ title: String, color: Color) -> some View {
        Button { /* TODO: wire action */ } label: {
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

    // MARK: - State Views

    private var loadingView: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ProgressView().scaleEffect(1.3).tint(Color.ftdAccentOrange)
            Text(String(localized: "Loading bookings…"))
                .font(.subheadline).foregroundStyle(Color.ftdTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ftdInputBackground)
    }

    private var emptyView: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Spacer()
            Image(systemName: "ticket")
                .font(.ftdHeroIcon)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.3))
            Text(String(localized: "No bookings found"))
                .font(.title3).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextSecondary)
            Text(String(localized: "Try adjusting the filter dates."))
                .font(.subheadline).multilineTextAlignment(.center)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.7))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ftdInputBackground)
    }

    private var comingSoonView: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Spacer()
            Image(systemName: viewModel.selectedTab.icon)
                .font(.ftdHeroIcon)
                .foregroundStyle(Color.ftdAccentOrange.opacity(0.3))
            Text("\(viewModel.selectedTab.rawValue) Bookings")
                .font(.title3).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextSecondary)
            Text(String(localized: "Coming soon"))
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.6))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ftdInputBackground)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Spacer()
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
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ftdInputBackground)
    }
}
