import Foundation
import Observation

// MARK: - Date group helper

struct StatementDateGroup: Identifiable {
    let id: String
    let displayHeader: String
    let items: [StatementItem]
}

// MARK: - ViewModel

@Observable
@MainActor
final class AgencyStatementViewModel {

    // MARK: - Date chip

    enum DateChip: String, CaseIterable, Identifiable {
        case today      = "Today"
        case yesterday  = "Yesterday"
        case sevenDays  = "7 days"
        case thirtyDays = "30 days"
        var id: String { rawValue }
    }

    // MARK: - Filter state

    var selectedChip: DateChip = .sevenDays
    var fromDate: Date = Calendar.current.startOfDay(for: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date())
    var toDate: Date? = nil
    var selectedType: String? = nil   // nil = All
    var searchText: String = ""

    // Stable key that drives .task(id:) — changes whenever any filter that requires an API
    // call changes. Using start-of-day dates prevents fractional-second differences from
    // creating unnecessary re-fetches when the DatePicker normalises the binding value.
    var filterKey: String {
        let from = apiFmt.string(from: fromDate)
        let to = toDate.map { apiFmt.string(from: $0) } ?? "open"
        return "\(from)|\(to)|\(selectedType ?? "All")"
    }

    // MARK: - API state

    private(set) var statements: [StatementItem] = []
    private(set) var availableTypes: [String] = []
    private(set) var isLoading: Bool = true
    private(set) var error: String? = nil

    // MARK: - Navigation state

    var selectedItem: StatementItem? = nil
    var isDetailPresented: Bool = false

    // MARK: - Export

    var exportURL: URL? = nil
    var showExportSheet: Bool = false

    // MARK: - Private

    private let authManager: AuthManager
    private let apiFmt: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - Computed

    var filteredStatements: [StatementItem] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return statements }
        return statements.filter { item in
            [item.trasactionType, item.transactionId, item.referenceNo,
             item.remarks, item.addRemarks, item.bookingBalance, item.withdrawAmount]
                .compactMap { $0?.lowercased() }
                .contains { $0.contains(query) }
        }
    }

    var groupedStatements: [StatementDateGroup] {
        var order: [String] = []
        var dict: [String: [StatementItem]] = [:]
        for item in filteredStatements {
            let key = dateKey(from: item.valueDate)
            if dict[key] == nil { order.append(key) }
            dict[key, default: []].append(item)
        }
        return order.map { key in
            StatementDateGroup(id: key, displayHeader: formatHeader(key), items: dict[key]!)
        }
    }

    // MARK: - Actions

    func selectChip(_ chip: DateChip) {
        selectedChip = chip
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        switch chip {
        case .today:
            fromDate = today
            toDate = nil
        case .yesterday:
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
            fromDate = yesterday
            toDate = yesterday
        case .sevenDays:
            fromDate = calendar.date(byAdding: .day, value: -7, to: today) ?? today
            toDate = nil
        case .thirtyDays:
            fromDate = calendar.date(byAdding: .day, value: -30, to: today) ?? today
            toDate = nil
        }
    }

    func fetch() async {
        isLoading = true
        error = nil
        defer { isLoading = false }

        let request = AgencyStatementRequest(
            fromDate: apiFmt.string(from: fromDate),
            toDate: toDate.map { apiFmt.string(from: $0) },
            transactionType: selectedType
        )

        do {
            let response = try await authManager.fetchStatement(request: request)
            if response.status {
                statements = response.data?.depositStatement ?? []
                if let types = response.data?.transactionTypes, !types.isEmpty {
                    availableTypes = types.keys.sorted()
                }
            } else {
                statements = []
                error = response.message ?? String(localized: "Failed to load statement.")
            }
        } catch is CancellationError {
            // Task cancelled by filter change; the next request will update the state.
        } catch let networkError as NetworkError {
            statements = []
            error = networkError.errorDescription
        } catch {
            statements = []
            self.error = error.localizedDescription
        }
    }

    func selectItem(_ item: StatementItem) {
        selectedItem = item
        isDetailPresented = true
    }

    func triggerExport() {
        exportURL = buildCSV()
        if exportURL != nil { showExportSheet = true }
    }

    // MARK: - Helpers

    private func dateKey(from raw: String?) -> String {
        guard let string = raw, string.count >= 10 else { return raw ?? "" }
        return String(string.prefix(10))
    }

    private func formatHeader(_ key: String) -> String {
        let parser = DateFormatter()
        parser.dateFormat = "yyyy-MM-dd"
        parser.locale = Locale(identifier: "en_US_POSIX")
        guard let date = parser.date(from: key) else { return key }
        let calendar = Calendar.current
        let display = DateFormatter()
        display.dateFormat = "d MMM yyyy"
        let formatted = display.string(from: date)
        if calendar.isDateInToday(date) { return "Today, \(formatted)" }
        if calendar.isDateInYesterday(date) { return "Yesterday, \(formatted)" }
        return formatted
    }

    private func buildCSV() -> URL? {
        let rows = filteredStatements
        guard !rows.isEmpty else { return nil }

        let displayFmt: DateFormatter = {
            let f = DateFormatter()
            f.dateFormat = "d MMM yyyy"
            f.locale = Locale(identifier: "en_US_POSIX")
            return f
        }()

        let agencyName = authManager.currentUser?.agencyName ?? ""
        let fromStr    = displayFmt.string(from: fromDate)
        let toStr      = toDate.map { displayFmt.string(from: $0) } ?? displayFmt.string(from: Date())
        let typeStr    = selectedType ?? "All"

        let meta = [
            "Agency Name:,\(agencyName)",
            "Report:,Agency Statement",
            "From Date:,\(fromStr)",
            "To Date:,\(toStr)",
            "Transaction Type:,\(typeStr)",
            "",
        ]

        let columnHeader = "Date,Type,Reference ID,Debit,Credit,Gross,Commission,Txn Fees,TDS,PG Fees,Balance,Credit Balance,Markup,Insurance,Remark"
        let lines = rows.map { item in
            [item.valueDate, item.trasactionType, item.transactionId,
             item.withdrawAmount, item.addBookingBalance, item.transactionAmount,
             item.commission, item.txnFees, item.tds, item.paymentCharge,
             item.bookingBalance, item.creditBalance, item.markup, item.insuranceCharge,
             item.remarks ?? item.addRemarks]
                .map { $0 ?? "" }
                .joined(separator: ",")
        }
        let csv = (meta + [columnHeader] + lines).joined(separator: "\n")
        let name = "Statement_\(apiFmt.string(from: fromDate)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
