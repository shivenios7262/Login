import SwiftUI

struct AgencyStatementView: View {
    @State private var viewModel: AgencyStatementViewModel
    @Environment(\.dismiss) private var dismiss

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
                    Circle()
                        .fill(Color.ftdCardBackground)
                        .frame(width: 36, height: 36)
                        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(Color.ftdTextPrimary)
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Text("Agency Statements")
                .font(.headline)
                .fontWeight(.bold)
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
        VStack(spacing: DesignTokens.Spacing.sm) {
            chipRow
            dateRow
            controlsRow
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
    }

    private var chipRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.sm) {
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
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : Color.ftdTextPrimary)
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, 7)
                .background(isSelected ? Color.ftdAccentOrange : Color.ftdInputBackground)
                .clipShape(Capsule())
                .overlay {
                    if !isSelected {
                        Capsule().stroke(Color.ftdBorder, lineWidth: 1)
                    }
                }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: viewModel.selectedChip)
    }

    private var typeDropdown: some View {
        Menu {
            ForEach(TransactionType.allCases) { type in
                Button {
                    viewModel.selectedType = type
                    // filterKey changes automatically — task(id:) restarts the fetch
                } label: {
                    Label(type.rawValue, systemImage: viewModel.selectedType == type ? "checkmark" : "")
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.selectedType == .all ? "All Type" : viewModel.selectedType.rawValue)
                    .font(.subheadline)
                    .lineLimit(1)
                Image(systemName: "chevron.down")
                    .font(.caption2)
            }
            .foregroundStyle(Color.ftdTextPrimary)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, 7)
            .background(Color.ftdInputBackground)
            .clipShape(Capsule())
            .overlay(Capsule().stroke(Color.ftdBorder, lineWidth: 1))
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
        HStack(spacing: 8) {
            Image(systemName: "calendar")
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
            DatePicker("", selection: $viewModel.fromDate, displayedComponents: .date)
                .datePickerStyle(.compact)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.ftdInputBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
        .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.field).stroke(Color.ftdBorder, lineWidth: 1))
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var toDatePicker: some View {
        if let date = viewModel.toDate {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                DatePicker(
                    "",
                    selection: Binding(get: { date }, set: { viewModel.toDate = $0 }),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                .frame(maxWidth: .infinity, alignment: .leading)
                Button { viewModel.toDate = nil } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.ftdTextSecondary)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.ftdInputBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
            .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.field).stroke(Color.ftdBorder, lineWidth: 1))
            .frame(maxWidth: .infinity)
        } else {
            Button { viewModel.toDate = Date() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "calendar")
                        .font(.subheadline)
                        .foregroundStyle(Color.ftdTextSecondary)
                    Text("To Date")
                        .font(.subheadline)
                        .foregroundStyle(Color.ftdTextSecondary.opacity(0.6))
                    Spacer()
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.ftdInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.field).stroke(Color.ftdBorder, lineWidth: 1))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Controls Row

    private var controlsRow: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.caption)
                    .foregroundStyle(Color.ftdTextSecondary)
                TextField("Search Transaction", text: $viewModel.searchText)
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextPrimary)
                    .autocorrectionDisabled()
                if !viewModel.searchText.isEmpty {
                    Button { viewModel.searchText = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.ftdTextSecondary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.ftdInputBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
            .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.field).stroke(Color.ftdBorder, lineWidth: 1))
            .frame(maxWidth: .infinity)

            Button { viewModel.triggerExport() } label: {
                HStack(spacing: 4) {
                    Image(systemName: "arrow.down.to.line")
                        .font(.caption)
                    Text("Export Excel")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color(red: 0.12, green: 0.56, blue: 0.27))
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
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
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextPrimary)
            Spacer()
            Text("\(group.items.count) Transactions")
                .font(.caption)
                .foregroundStyle(Color.ftdTextSecondary)
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(Color.ftdAccentTeal.opacity(0.10))
    }

    private func transactionRow(_ item: StatementItem) -> some View {
        Button { viewModel.selectItem(item) } label: {
            VStack(spacing: DesignTokens.Spacing.xs) {
                HStack(alignment: .top) {
                    Text(item.trasactionType ?? "Transaction")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.ftdTextPrimary)
                        .lineLimit(1)
                    Spacer()
                    rowAmountView(item)
                }
                HStack {
                    Text("Ref ID: \(item.transactionId ?? item.referenceNo ?? "-")")
                        .font(.caption)
                        .foregroundStyle(Color.ftdTextSecondary)
                        .lineLimit(1)
                    Spacer()
                    Text(formatListDate(item.valueDate))
                        .font(.caption)
                        .foregroundStyle(Color.ftdTextSecondary)
                }
                HStack {
                    Text("Credit Balance ₹\(item.creditBalance ?? "0")")
                        .font(.caption)
                        .foregroundStyle(Color.ftdTextSecondary)
                    Spacer()
                    Text("Balance ₹\(item.bookingBalance ?? "0")")
                        .font(.caption)
                        .foregroundStyle(Color.ftdTextSecondary)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.md)
            .background(Color.ftdCardBackground)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func rowAmountView(_ item: StatementItem) -> some View {
        let debit = item.withdrawAmount?.trimmingCharacters(in: .whitespaces) ?? ""
        let credit = item.addBookingBalance?.trimmingCharacters(in: .whitespaces) ?? ""
        let isDebit = !debit.isEmpty && debit != "0" && debit != "0.0"
        if isDebit {
            Text("– ₹\(debit)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color(red: 0.85, green: 0.15, blue: 0.15))
        } else {
            Text("+ ₹\(credit.isEmpty || credit == "0" || credit == "0.0" ? "0" : credit)")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color(red: 0.10, green: 0.60, blue: 0.25))
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
