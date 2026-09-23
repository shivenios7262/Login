import SwiftUI
import UIKit

// MARK: - StatementView

struct StatementView: View {
    @Bindable var viewModel: StatementViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var exportFile: ExportFile?

    private struct ExportFile: Identifiable {
        let url: URL
        var id: String { url.lastPathComponent }
    }

    // MARK: - Column layout

    private struct Col {
        let title: String
        let width: CGFloat
        let trailing: Bool
    }

    private static let cols: [Col] = [
        Col(title: "S.No",       width: 50,  trailing: false),
        Col(title: "Date",       width: 155, trailing: false),
        Col(title: "Type",       width: 190, trailing: false),
        Col(title: "Ref. ID",    width: 185, trailing: false),
        Col(title: "Debit",      width: 82,  trailing: true),
        Col(title: "Credit",     width: 82,  trailing: true),
        Col(title: "Gross",      width: 82,  trailing: true),
        Col(title: "Comm",       width: 72,  trailing: true),
        Col(title: "Txn Fees",   width: 78,  trailing: true),
        Col(title: "TDS",        width: 60,  trailing: true),
        Col(title: "PG Fees",    width: 78,  trailing: true),
        Col(title: "Balance",    width: 92,  trailing: true),
        Col(title: "Cr.Balance", width: 92,  trailing: true),
        Col(title: "Markup",     width: 76,  trailing: true),
        Col(title: "Ins",        width: 66,  trailing: true),
        Col(title: "Remark",     width: 215, trailing: false),
    ]

    private static var tableWidth: CGFloat { cols.reduce(0) { $0 + $1.width } }
    private static let pageWindowHalf = 2  // show current±2, giving a max 5-page window

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            navBar
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    filterCard
                    if !viewModel.statements.isEmpty {
                        formulaBar
                    }
                    controlsRow
                    tableSection
                    if !viewModel.pagedStatements.isEmpty {
                        paginationBar
                    }
                    Spacer(minLength: 32)
                }
            }
        }
        .background(Color.ftdInputBackground)
        .task { await viewModel.fetchStatement() }
        .onChange(of: viewModel.searchText) { viewModel.resetPagination() }
        .onChange(of: viewModel.pageSize)   { viewModel.resetPagination() }
        .sheet(item: $exportFile) { file in
            ActivityShareView(url: file.url)
                .presentationDetents([.medium])
        }
    }

    // MARK: - Nav Bar

    private var navBar: some View {
        HStack {
            Text("Statement")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color.ftdTextPrimary)
            Spacer()
            Button { dismiss() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.ftdTextSecondary)
            }
            .accessibilityLabel("Dismiss")
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    // MARK: - Filter Card

    private var filterCard: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                // From Date — always present
                VStack(alignment: .leading, spacing: 3) {
                    Text("From Date")
                        .font(.caption2)
                        .foregroundStyle(Color.ftdTextSecondary)
                    DatePicker("", selection: $viewModel.fromDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxWidth: .infinity)

                // To Date — optional
                VStack(alignment: .leading, spacing: 3) {
                    Text("To Date")
                        .font(.caption2)
                        .foregroundStyle(Color.ftdTextSecondary)
                    toDateField
                }
                .frame(maxWidth: .infinity)
            }

            HStack(spacing: DesignTokens.Spacing.sm) {
                // Transaction type dropdown
                VStack(alignment: .leading, spacing: 3) {
                    Text("Type of Transaction")
                        .font(.caption2)
                        .foregroundStyle(Color.ftdTextSecondary)
                    transactionTypeMenu
                }
                .frame(maxWidth: .infinity)

                // Search button
                Button {
                    Task { await viewModel.search() }
                } label: {
                    Text("Search")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .padding(.horizontal, DesignTokens.Spacing.lg)
                        .padding(.vertical, 10)
                        .background(Color.ftdAccentOrange)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
                }
                .buttonStyle(.plain)
                .padding(.top, 15) // align with fields
            }
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    @ViewBuilder
    private var toDateField: some View {
        if let date = viewModel.toDate {
            HStack(spacing: 4) {
                DatePicker(
                    "",
                    selection: Binding(get: { date }, set: { viewModel.toDate = $0 }),
                    displayedComponents: .date
                )
                .datePickerStyle(.compact)
                .labelsHidden()
                Button { viewModel.toDate = nil } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(Color.ftdTextSecondary)
                }
                .buttonStyle(.plain)
            }
        } else {
            Button {
                viewModel.toDate = Date()
            } label: {
                HStack {
                    Text("Eg: YYYY-MM-DD")
                        .font(.subheadline)
                        .foregroundStyle(Color.ftdTextSecondary.opacity(0.6))
                    Spacer()
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundStyle(Color.ftdTextSecondary.opacity(0.5))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(Color.ftdInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.field).stroke(Color.ftdBorder))
            }
            .buttonStyle(.plain)
        }
    }

    private var transactionTypeMenu: some View {
        Menu {
            ForEach(TransactionType.allCases) { type in
                Button {
                    viewModel.selectedTransactionType = type
                } label: {
                    Label(type.rawValue,
                          systemImage: viewModel.selectedTransactionType == type ? "checkmark" : "")
                }
            }
        } label: {
            HStack {
                Text(viewModel.selectedTransactionType.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextPrimary)
                    .lineLimit(1)
                Spacer(minLength: 4)
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .foregroundStyle(Color.ftdTextSecondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.ftdInputBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
            .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.field).stroke(Color.ftdBorder))
        }
    }

    // MARK: - Formula Bar

    private var formulaBar: some View {
        Text("Charged = Gross(Including Insurance) - Commission + Txn Fees + TDS")
            .font(.caption2)
            .foregroundStyle(Color.ftdTextSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .background(Color.ftdCardBackground.opacity(0.6))
    }

    // MARK: - Controls Row (page size, export, keyword search)

    private var controlsRow: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            // Page size
            Menu {
                ForEach(viewModel.pageSizeOptions, id: \.self) { size in
                    Button("\(size)") { viewModel.pageSize = size }
                }
            } label: {
                HStack(spacing: 3) {
                    Text("\(viewModel.pageSize)")
                        .font(.subheadline)
                        .foregroundStyle(Color.ftdTextPrimary)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(Color.ftdTextSecondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.ftdCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.field).stroke(Color.ftdBorder))
            }

            // Export CSV button
            Button {
                if let url = viewModel.exportCSV() { exportFile = ExportFile(url: url) }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "tablecells")
                        .font(.caption)
                    Text("Excel")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(Color.ftdExcelGreen)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
            }
            .buttonStyle(.plain)

            // Keyword search
            HStack(spacing: 6) {
                Image(systemName: "magnifyingglass")
                    .font(.caption)
                    .foregroundStyle(Color.ftdTextSecondary)
                TextField("Search...", text: $viewModel.searchText)
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
            .padding(.vertical, 7)
            .background(Color.ftdCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
            .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.field).stroke(Color.ftdBorder))
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(Color.ftdInputBackground)
    }

    // MARK: - Table Section

    @ViewBuilder
    private var tableSection: some View {
        if viewModel.isLoadingStatement {
            loadingView
        } else if let err = viewModel.statementError {
            errorView(err)
        } else if viewModel.statements.isEmpty {
            emptyView
        } else {
            tableContent
        }
    }

    private var tableContent: some View {
        ScrollView(.horizontal, showsIndicators: true) {
            VStack(spacing: 0) {
                tableHeader
                Divider()
                    .background(Color.ftdBorder)
                ForEach(Array(viewModel.pagedStatements.enumerated()), id: \.element.id) { idx, item in
                    tableRow(item, serial: viewModel.showingFrom + idx)
                    Divider()
                        .background(Color.ftdBorder.opacity(0.5))
                }
            }
            .frame(minWidth: Self.tableWidth)
        }
        .background(Color.ftdCardBackground)
        .shadow(color: .black.opacity(0.04), radius: 3, y: 1)
    }

    private var tableHeader: some View {
        HStack(spacing: 0) {
            ForEach(Self.cols.indices, id: \.self) { i in
                let col = Self.cols[i]
                Text(col.title)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .textCase(.uppercase)
                    .tracking(0.3)
                    .lineLimit(2)
                    .multilineTextAlignment(col.trailing ? .trailing : .leading)
                    .frame(width: col.width, alignment: col.trailing ? .trailing : .leading)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 8)
                if i < Self.cols.count - 1 {
                    Divider()
                        .frame(height: 28)
                        .background(Color.ftdBorder.opacity(0.4))
                }
            }
        }
        .background(Color.ftdInputBackground)
    }

    private func tableRow(_ item: StatementItem, serial: Int) -> some View {
        let isEven = serial.isMultiple(of: 2)
        return HStack(spacing: 0) {
            // S.No
            plainCell(String(serial), col: 0, color: Color.ftdTextSecondary)
            // Date
            plainCell(item.valueDate ?? "-", col: 1, color: Color.ftdTextPrimary)
            // Type
            plainCell(item.trasactionType ?? "-", col: 2, color: Color.ftdTextPrimary)
            // Ref ID
            plainCell(item.transactionId ?? "-", col: 3, color: Color.ftdTextPrimary)
            // Debit — red when non-zero
            numCell(item.withdrawAmount, col: 4, highlight: .debit)
            // Credit — green when non-zero
            numCell(item.addBookingBalance, col: 5, highlight: .credit)
            // Gross
            numCell(item.transactionAmount, col: 6, highlight: .neutral)
            // Comm
            numCell(item.commission, col: 7, highlight: .neutral)
            // Txn Fees
            numCell(item.txnFees, col: 8, highlight: .neutral)
            // TDS
            numCell(item.tds, col: 9, highlight: .neutral)
            // PG Fees
            numCell(item.paymentCharge, col: 10, highlight: .neutral)
            // Balance
            numCell(item.bookingBalance, col: 11, highlight: .neutral)
            // Cr. Balance
            numCell(item.creditBalance, col: 12, highlight: .neutral)
            // Markup
            numCell(item.markup, col: 13, highlight: .neutral)
            // Ins
            numCell(item.insuranceCharge, col: 14, highlight: .neutral)
            // Remark — prefer addRemarks (longer description) over remarks
            plainCell(remarkText(item), col: 15, color: Color.ftdTextSecondary)
        }
        .background(isEven ? Color.ftdCardBackground : Color.ftdInputBackground.opacity(0.5))
    }

    private func remarkText(_ item: StatementItem) -> String {
        let r1 = item.addRemarks?.trimmingCharacters(in: .whitespaces) ?? ""
        let r2 = item.remarks?.trimmingCharacters(in: .whitespaces) ?? ""
        if !r1.isEmpty { return r1 }
        if !r2.isEmpty { return r2 }
        return "-"
    }

    // MARK: - Cell helpers

    private enum NumHighlight { case debit, credit, neutral }

    private func plainCell(_ text: String, col: Int, color: Color) -> some View {
        let c = Self.cols[col]
        return Text(text.isEmpty ? "-" : text)
            .font(.caption)
            .foregroundStyle(color)
            .lineLimit(2)
            .multilineTextAlignment(c.trailing ? .trailing : .leading)
            .frame(width: c.width, alignment: c.trailing ? .trailing : .leading)
            .padding(.horizontal, 6)
            .padding(.vertical, 8)
    }

    private func numCell(_ val: String?, col: Int, highlight: NumHighlight) -> some View {
        let c = Self.cols[col]
        let text = val?.trimmingCharacters(in: .whitespaces) ?? ""
        let isZeroOrEmpty = text.isEmpty || Double(text) == 0
        let display = isZeroOrEmpty ? "0" : text

        let color: Color = {
            if isZeroOrEmpty { return Color.ftdTextSecondary.opacity(0.5) }
            switch highlight {
            case .debit:   return Color.ftdDebitRed
            case .credit:  return Color.ftdCreditGreen
            case .neutral: return Color.ftdTextPrimary
            }
        }()

        return Text(display)
            .font(.caption)
            .foregroundStyle(color)
            .frame(width: c.width, alignment: .trailing)
            .padding(.horizontal, 6)
            .padding(.vertical, 8)
    }

    // MARK: - Pagination Bar

    private var paginationBar: some View {
        HStack {
            Text("Showing \(viewModel.showingFrom) to \(viewModel.showingTo) of \(viewModel.totalCount) entries")
                .font(.caption)
                .foregroundStyle(Color.ftdTextSecondary)

            Spacer()

            HStack(spacing: 4) {
                pageButton("PREV", enabled: viewModel.currentPage > 1) {
                    viewModel.prevPage()
                }
                ForEach(visiblePages, id: \.self) { page in
                    pageNumberButton(page)
                }
                pageButton("NEXT", enabled: viewModel.currentPage < viewModel.totalPages) {
                    viewModel.nextPage()
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
        .background(Color.ftdCardBackground)
        .shadow(color: .black.opacity(0.04), radius: 3, y: -1)
    }

    private var visiblePages: [Int] {
        let total = viewModel.totalPages
        guard total > 1 else { return [1] }
        let cur = viewModel.currentPage
        var start = max(1, cur - Self.pageWindowHalf)
        let end   = min(total, start + Self.pageWindowHalf * 2)
        start = max(1, end - Self.pageWindowHalf * 2)
        return Array(start...end)
    }

    private func pageButton(_ label: String, enabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(enabled ? Color.ftdTextPrimary : Color.ftdTextSecondary.opacity(0.4))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.ftdInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.ftdBorder, lineWidth: 1))
        }
        .buttonStyle(.plain)
        .disabled(!enabled)
    }

    private func pageNumberButton(_ page: Int) -> some View {
        let isActive = page == viewModel.currentPage
        return Button { viewModel.goToPage(page) } label: {
            Text("\(page)")
                .font(.caption2)
                .fontWeight(isActive ? .bold : .regular)
                .foregroundStyle(isActive ? .white : Color.ftdTextPrimary)
                .frame(minWidth: 28)
                .padding(.vertical, 5)
                .background(isActive ? Color.ftdAccentOrange : Color.ftdInputBackground)
                .clipShape(RoundedRectangle(cornerRadius: 5))
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(isActive ? Color.clear : Color.ftdBorder, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - State views

    private var loadingView: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ProgressView()
                .scaleEffect(1.2)
            Text("Loading statement...")
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
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
            Button("Retry") {
                Task { await viewModel.search() }
            }
            .buttonStyle(.borderedProminent)
            .tint(Color.ftdAccentOrange)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal, DesignTokens.Spacing.lg)
    }

    private var emptyView: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.largeTitle)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.4))
            Text("No transactions found")
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
            Text("Try adjusting the date range or transaction type.")
                .font(.caption)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
        .padding(.horizontal, DesignTokens.Spacing.lg)
    }
}

// MARK: - UIActivityViewController wrapper

struct ActivityShareView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
