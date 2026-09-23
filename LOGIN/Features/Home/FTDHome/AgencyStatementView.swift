import SwiftUI

struct AgencyStatementView: View {
    @State private var viewModel: AgencyStatementViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showFromDatePicker = false
    @State private var showToDatePicker   = false

    private static let displayFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    init(authManager: AuthManager) {
        _viewModel = State(initialValue: AgencyStatementViewModel(authManager: authManager))
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                navBar
                filterArea
                    .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
                contentArea
            }
            .background(Color.ftdInputBackground)
            .toolbar(.hidden, for: .navigationBar)
            .task(id: viewModel.filterKey) {
                await viewModel.fetch()
            }
            .navigationDestination(isPresented: $viewModel.isDetailPresented) {
                if let item = viewModel.selectedItem {
                    TransactionDetailView(item: item)
                }
            }
            .sheet(isPresented: $viewModel.showExportSheet) {
                if let url = viewModel.exportURL {
                    ActivityShareView(url: url)
                        .presentationDetents([.medium])
                }
            }
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            Button { dismiss() } label: {
                ZStack {
//                    Circle()
//                        .fill(Color.ftdCardBackground)
//                        .frame(width: 36, height: 36)
//                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                    Image("backImg")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.ftdTextPrimary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Agency Statement")
                .font(.ftdSectionHeaderMedium)
                .foregroundStyle(Color.ftdTextPrimary)

            Spacer()

            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    // MARK: - Filter Area

    private var filterArea: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            chipRow
            dateRow
            controlsRow
                .padding(.bottom, DesignTokens.Spacing.md)
        }
        .padding(DesignTokens.Spacing.md)
       // .padding(.top, DesignTokens.Spacing.sm)
//        .padding(.bottom, DesignTokens.Spacing.sm)
        .background(Color.ftdCardBackground)
    }

    private var chipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.md) {
                ForEach(AgencyStatementViewModel.DateChip.allCases) { chip in
                    chipButton(chip)
                }
                typeDropdown
            }
        }
    }

    private func chipButton(_ chip: AgencyStatementViewModel.DateChip) -> some View {
        let isSelected = viewModel.selectedChip == chip
        return Button { viewModel.selectChip(chip) } label: {
            Text(chip.rawValue)
                .font(.ftdLabelXS)
                .foregroundStyle(isSelected ? Color.ftdAccentOrange : Color.ftdChipDeselectedText)
                .padding(.horizontal, DesignTokens.Spacing.xs)
                .frame(height: 28)
                .background(isSelected ? Color.ftdAccentOrangeAlpha : Color.ftdChipDeselectedBg)
                .clipShape(RoundedRectangle(cornerRadius: 7))
                .overlay {
                    RoundedRectangle(cornerRadius: 7)
                        .stroke(isSelected ? Color.ftdChipSelectedBg : Color.ftdDivider, lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: viewModel.selectedChip)
    }

    private var typeDropdown: some View {
        Menu {
            Button {
                viewModel.selectedType = nil
            } label: {
                Label("All Type", systemImage: viewModel.selectedType == nil ? "checkmark" : "")
            }
            ForEach(viewModel.availableTypes, id: \.self) { type in
                Button {
                    viewModel.selectedType = type
                } label: {
                    Label(type, systemImage: viewModel.selectedType == type ? "checkmark" : "")
                }
            }
        } label: {
            let isTypeSelected = viewModel.selectedType != nil
            HStack(spacing: 4) {
                Text(viewModel.selectedType ?? "All Type")
                    .font(.ftdLabelXS)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .foregroundStyle(isTypeSelected ? Color.ftdAccentOrange : Color.ftdChipDeselectedText)
            .padding(.horizontal, DesignTokens.Spacing.sm)
            .frame(height: 28)
            .background(isTypeSelected ? Color.ftdAccentOrangeAlpha : Color.ftdChipDeselectedBg)
            .clipShape(RoundedRectangle(cornerRadius: 7))
            .overlay {
                RoundedRectangle(cornerRadius: 7)
                    .stroke(isTypeSelected ? Color.ftdChipSelectedBg : Color.ftdDivider, lineWidth: 1)
            }
        }
    }

    // MARK: - Date Row (no onChange — filterKey handles re-fetch automatically)

    private var dateRow: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            fromDatePicker
            toDatePicker
        }
    }

    private var fromDatePicker: some View {
        Button { showFromDatePicker = true } label: {
            dateFieldLabel(
                icon: "cal",
                text: Self.displayFmt.string(from: viewModel.fromDate),
                isPlaceholder: false
            )
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showFromDatePicker) {
            datePickerSheet(title: "From Date", date: $viewModel.fromDate) {
                showFromDatePicker = false
            }
        }
    }

    private var toDatePicker: some View {
        Button {
            if viewModel.toDate == nil { viewModel.toDate = Date() }
            showToDatePicker = true
        } label: {
            HStack(spacing: 8) {
                dateFieldLabel(
                    icon: "cal",
                    text: viewModel.toDate.map { Self.displayFmt.string(from: $0) } ?? "To Date",
                    isPlaceholder: viewModel.toDate == nil
                )
                if viewModel.toDate != nil {
                    Button { viewModel.toDate = nil } label: {
                        Image( "cancel")
                            //.font(.caption)
                            .foregroundStyle(Color.ftdTextSecondary)
                    }
                    .buttonStyle(.plain)
                    .padding(.trailing, 10)
                }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showToDatePicker) {
            datePickerSheet(
                title: "To Date",
                date: Binding(
                    get: { viewModel.toDate ?? Date() },
                    set: { viewModel.toDate = $0 }
                )
            ) {
                showToDatePicker = false
            }
        }
    }

    private func dateFieldLabel(icon: String, text: String, isPlaceholder: Bool) -> some View {
        HStack(spacing: 8) {
            Image(icon)
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
            Text(text)
                .font(.ftdBodySM)
                .foregroundStyle(isPlaceholder ? Color.ftdTextTertiary/*.opacity(0.5)*/ : Color.ftdTextSecondary)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
        //.background(Color.ftdInputBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
        .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.field).stroke(Color.ftdBorder, lineWidth: 1))
    }

    private func datePickerSheet(title: String, date: Binding<Date>, onDone: @escaping () -> Void) -> some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            Text(title)
                .font(.ftdSectionHeaderMedium)
                .foregroundStyle(Color.ftdTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.lg)
            DatePicker("", selection: date, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .tint(Color.ftdAccentOrange)
                .labelsHidden()
                .padding(.horizontal, DesignTokens.Spacing.lg)
            FTDPrimaryButton(title: "Done") { onDone() }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.lg)
        }
        .presentationDetents([.large])
        .background(Color.ftdCardBackground)
    }

    // MARK: - Controls Row

    private var controlsRow: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            HStack(spacing: 6) {
                Image( "search")
                    .font(.caption)
                    .foregroundStyle(Color.ftdTextSecondary)
                TextField("Search Transaction", text: $viewModel.searchText)
                    .font(.ftdBodySM)
                    //.foregroundStyle(Color.ftdTextPrimary)
                    .autocorrectionDisabled()
                if !viewModel.searchText.isEmpty {
                    Button { viewModel.searchText = "" } label: {
                        Image("cancel")
                            .font(.caption)
                            .foregroundStyle(Color.ftdTextSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            //.background(Color.ftdInputBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
            .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.field).stroke(Color.ftdBorder, lineWidth: 1))
            .frame(maxWidth: .infinity)

            Button { viewModel.triggerExport() } label: {
                HStack(spacing: 4) {
                    Image("download")
                        .font(.caption)
                    Text("Export CSV")
                        .font(.ftdBodySM)
                       
                }
                .foregroundStyle(Color.ftdTextSecondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                //.background(Color.ftdExcelGreen)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.field).stroke(Color.ftdBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)
        }
    }

    // MARK: - Content

    @ViewBuilder
    private var contentArea: some View {
        if viewModel.isLoading {
            loadingView
        } else if let err = viewModel.error {
            errorView(err)
        } else if viewModel.groupedStatements.isEmpty {
            emptyView
        } else {
            transactionList
        }
    }

    // MARK: - Transaction List

    private var transactionList: some View {
        ScrollView(showsIndicators: false) {
            LazyVStack(spacing: 0, pinnedViews: .sectionHeaders) {
                ForEach(viewModel.groupedStatements) { group in
                    Section {
                        ForEach(group.items) { item in
                            transactionRow(item)
                            Divider()
                                .padding(.leading, DesignTokens.Spacing.lg)
                        }
                    } header: {
                        groupHeader(group)
                    }
                }
            }
        }
        .background(Color.ftdInputBackground)
    }

    private func groupHeader(_ group: StatementDateGroup) -> some View {
        HStack {
            Text(group.displayHeader)
                .font(.ftdLabelMD)
                .fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextPrimary)
            Spacer()
            Text("\(group.items.count) Transactions")
                .font(.ftdBodySM)
                .foregroundStyle(Color.ftdTextTertiary)
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .frame(height: 41)
        .background(Color.ftdStatementSectionBg)
    }

    private func transactionRow(_ item: StatementItem) -> some View {
        Button { viewModel.selectItem(item) } label: {
            VStack(spacing: DesignTokens.Spacing.sm) {
                HStack(alignment: .top) {
                    Text(item.trasactionType ?? "Transaction")
                        .font(.ftdLabelMD)
                        .foregroundStyle(Color.ftdTextPrimary)
                        .lineLimit(1)
                    Spacer()
                    rowAmountView(item)
                }
                HStack {
                    Text("Ref ID: \(item.transactionId ?? item.referenceNo ?? "-")")
                        .font(.ftdPlaceholder)
                        .foregroundStyle(Color.ftdTextTertiary)
                        .lineLimit(1)
                    Spacer()
                    Text(formatListDate(item.valueDate))
                        .font(.ftdPlaceholder)
                        .foregroundStyle(Color.ftdTextTertiary)
                }
//                HStack {
//                    Text("Credit Balance ₹\(item.creditBalance ?? "0")")
//                        .font(.caption)
//                        .foregroundStyle(Color.ftdTextSecondary)
//                    Spacer()
//                    Text("Balance ₹\(item.bookingBalance ?? "0")")
//                        .font(.ftdLabelMD)
//                        .foregroundStyle(Color.ftdTextSecondary)
//                }
//                Text("Balance ₹\(item.bookingBalance ?? "0")")
//                    .font(.ftdLabelMD)
//                    .foregroundStyle(Color.ftdTextSecondary)
//                    .frame(maxWidth: .infinity, alignment: .trailing)
//                Text("Balance ")
//                        .font(.caption) // Style for the label
//                        .foregroundStyle(Color.ftdTextSecondary)
//                    +
//                    Text("₹\(item.bookingBalance ?? "0")")
//                        .font(.ftdLabelMD) // Style for the actual number
//                        .foregroundStyle(Color.primary) // Example: making the amount stand out more
                (
                    Text("Balance ")
                        .font(.ftdPlaceholder)
                        .foregroundStyle(Color.ftdTextTertiary)
                    +
                    Text("₹\(item.bookingBalance ?? "0")")
                        .font(.ftdLabelXS)
                        .foregroundStyle(Color.ftdTextSecondary)
                )
                .frame(maxWidth: .infinity, alignment: .trailing)
                        
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .padding(.bottom, DesignTokens.Spacing.md)
            .background(Color.ftdCardBackground)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func rowAmountView(_ item: StatementItem) -> some View {
        let debit = item.withdrawAmount?.trimmingCharacters(in: .whitespaces) ?? ""
        let credit = item.addBookingBalance?.trimmingCharacters(in: .whitespaces) ?? ""
        let isDebit = !debit.isEmpty && Double(debit) != 0
        if isDebit {
            Text("– ₹\(debit)")
                .font(.ftdLabelMD)
                
                .foregroundStyle(Color.ftdDebitRed)
        } else {
            Text("+ ₹\(credit.isEmpty || Double(credit) == 0 ? "0" : credit)")
                .font(.ftdLabelMD)
                
                .foregroundStyle(Color.ftdCreditGreen)
        }
    }

    // MARK: - State Views

    private var loadingView: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Spacer()
            ProgressView().scaleEffect(1.2)
            Text("Loading transactions...")
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Spacer()
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundStyle(Color.ftdDestructiveRed)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
                .multilineTextAlignment(.center)
            Button("Retry") { Task { await viewModel.fetch() } }
                .buttonStyle(.borderedProminent)
                .tint(Color.ftdAccentOrange)
            Spacer()
        }
        .padding(DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity)
    }

    private var emptyView: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Spacer()
            Image(systemName: "doc.text.magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.4))
            Text("No transactions found")
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
            Text("Try a different date range or filter.")
                .font(.caption)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.7))
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Date helpers

    private func formatListDate(_ raw: String?) -> String {
        guard let s = raw, s.count >= 10 else { return raw ?? "" }
        let key = String(s.prefix(10))
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        parser.locale = Locale(identifier: "en_US_POSIX")
        guard let date = parser.date(from: key) else { return s }
        let display = DateFormatter()
        display.dateFormat = "d MMM yyyy"
        if s.count > 10 {
            let timePart = String(s.dropFirst(11).prefix(8))
            let timeFmt = DateFormatter()
            timeFmt.dateFormat = "HH:mm:ss"
            if let timeDate = timeFmt.date(from: timePart) {
                let timeDsp = DateFormatter()
                timeDsp.dateFormat = "hh:mm a"
                return "\(display.string(from: date)) • \(timeDsp.string(from: timeDate))"
            }
        }
        return display.string(from: date)
    }
}
