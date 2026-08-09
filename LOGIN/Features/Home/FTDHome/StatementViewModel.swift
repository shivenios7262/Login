import Foundation
import Observation

// MARK: - Transaction Type

enum TransactionType: String, CaseIterable, Identifiable {
    case all            = "All"
    case onlineTransfer = "Online Transfer"
    case cheque         = "Cheque"
    case cash           = "Cash"
    case creditRequest  = "Credit Request"
    case recharge       = "Recharge"
    case busBooking     = "Bus Booking"
    case flightBooking  = "Flight Booking"
    case busRefund      = "Bus Refund"
    case flightRefund   = "Flight Refund"
    case offlineCharge  = "Offline Charge"
    case offlineRefund  = "Offline Refund"

    var id: String { rawValue }
    // "All" sends nil so the field is omitted from the JSON body.
    var apiValue: String? { self == .all ? nil : rawValue }
}

// MARK: - ViewModel

@Observable
@MainActor
final class StatementViewModel: StatementProvider {

    // MARK: - Filter state (drives API call)

    var fromDate: Date = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
    var toDate: Date? = nil
    var selectedTransactionType: TransactionType = .all

    // MARK: - StatementProvider conformance

    private(set) var statements: [StatementItem] = []
    private(set) var isLoadingStatement = false
    private(set) var statementError: String? = nil

    // MARK: - Pagination

    var currentPage = 1
    var pageSize = 10
    let pageSizeOptions = [10, 25, 50, 100]

    // MARK: - Keyword search (client-side, on fetched data)

    var searchText = ""

    // MARK: - Derived

    var filteredStatements: [StatementItem] {
        let q = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !q.isEmpty else { return statements }
        return statements.filter { item in
            [item.trasactionType, item.transactionId, item.referenceNo,
             item.remarks, item.addRemarks, item.bookingBalance, item.withdrawAmount]
                .compactMap { $0?.lowercased() }
                .contains { $0.contains(q) }
        }
    }

    var pagedStatements: [StatementItem] {
        let src = filteredStatements
        let start = (currentPage - 1) * pageSize
        guard start < src.count else { return [] }
        return Array(src[start..<min(start + pageSize, src.count)])
    }

    var totalPages: Int { max(1, Int(ceil(Double(filteredStatements.count) / Double(pageSize)))) }
    var showingFrom: Int { filteredStatements.isEmpty ? 0 : (currentPage - 1) * pageSize + 1 }
    var showingTo: Int   { min(currentPage * pageSize, filteredStatements.count) }
    var totalCount: Int  { filteredStatements.count }

    // Export uses full API dataset when no keyword is active, filtered otherwise.
    var exportData: [StatementItem] {
        searchText.trimmingCharacters(in: .whitespaces).isEmpty ? statements : filteredStatements
    }

    // MARK: - Private

    private let authManager: AuthManager
    private let apiFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - StatementProvider — initial auto-load

    func fetchStatement() async {
        await performFetch()
    }

    // MARK: - Search button action

    func search() async {
        currentPage = 1
        await performFetch()
    }

    // MARK: - Pagination helpers

    func goToPage(_ page: Int) { currentPage = max(1, min(page, totalPages)) }
    func nextPage() { if currentPage < totalPages { currentPage += 1 } }
    func prevPage() { if currentPage > 1 { currentPage -= 1 } }
    func resetPagination() { currentPage = 1 }

    // MARK: - CSV export

    func exportCSV() -> URL? {
        let rows = exportData
        guard !rows.isEmpty else { return nil }

        let header = "S.No,Date,Type,Reference ID,Debit,Credit,Gross,Comm,Txn Fees,TDS,PG Fees,Balance,Credit Balance,Markup,Ins,Remark"
        let lines: [String] = rows.enumerated().map { idx, item in
            [
                "\(idx + 1)",
                csvEscape(item.valueDate),
                csvEscape(item.trasactionType),
                csvEscape(item.transactionId),
                csvEscape(item.withdrawAmount),
                csvEscape(item.addBookingBalance),
                csvEscape(item.transactionAmount),
                csvEscape(item.commission),
                csvEscape(item.txnFees),
                csvEscape(item.tds),
                csvEscape(item.paymentCharge),
                csvEscape(item.bookingBalance),
                csvEscape(item.creditBalance),
                csvEscape(item.markup),
                csvEscape(item.insuranceCharge),
                csvEscape(item.remarks ?? item.addRemarks)
            ].joined(separator: ",")
        }

        let csv = ([header] + lines).joined(separator: "\n")
        let toStr = toDate.map { apiFmt.string(from: $0) } ?? apiFmt.string(from: Date())
        let name = "Statement_\(apiFmt.string(from: fromDate))_to_\(toStr).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    // MARK: - Private helpers

    private func performFetch() async {
        isLoadingStatement = true
        statementError = nil
        defer { isLoadingStatement = false }

        let request = AgencyStatementRequest(
            fromDate: apiFmt.string(from: fromDate),
            toDate:   toDate.map { apiFmt.string(from: $0) },
            transactionType: selectedTransactionType.apiValue
        )

        do {
            let response = try await authManager.fetchStatement(request: request)
            if response.status {
                statements = response.data?.depositStatement ?? []
            } else {
                statements = []
                statementError = response.message ?? String(localized: "Failed to load statement.")
            }
        } catch let e as NetworkError {
            statementError = e.errorDescription
        } catch {
            statementError = error.localizedDescription
        }
    }

    private func csvEscape(_ s: String?) -> String {
        guard let s, !s.isEmpty else { return "" }
        if s.contains(",") || s.contains("\"") || s.contains("\n") {
            return "\"\(s.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return s
    }
}
