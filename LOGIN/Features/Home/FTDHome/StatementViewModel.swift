import Foundation
import Observation

@Observable
@MainActor
final class StatementViewModel: StatementProvider {
    private(set) var statements: [StatementItem] = []
    private(set) var isLoadingStatement = false
    private(set) var statementError: String? = nil

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func fetchStatement() async {
        isLoadingStatement = true
        statementError = nil
        defer { isLoadingStatement = false }

        let today = Date()
        let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: today) ?? today
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"

        let request = AgencyStatementRequest(
            fromDate: fmt.string(from: fromDate),
            toDate: fmt.string(from: today)
        )
        do {
            let response = try await authManager.fetchStatement(request: request)
            statements = response.status ? (response.data ?? []) : []
            if !response.status {
                statementError = response.message ?? String(localized: "Failed to load statement.")
            }
        } catch let e as NetworkError { statementError = e.errorDescription
        } catch { statementError = error.localizedDescription }
    }
}
