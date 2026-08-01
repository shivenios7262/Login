import Foundation
import Observation

@Observable
@MainActor
final class MarkupsViewModel: MarkupsProvider {
    private(set) var markups: [MarkupItem] = []
    private(set) var isLoadingMarkups = false
    private(set) var markupsError: String? = nil

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func fetchMarkups() async {
        isLoadingMarkups = true
        markupsError = nil
        defer { isLoadingMarkups = false }
        do {
            let response = try await authManager.fetchMarkups()
            markups = response.status ? (response.data ?? []) : []
            if !response.status {
                markupsError = response.message ?? String(localized: "Failed to load markups.")
            }
        } catch let e as NetworkError { markupsError = e.errorDescription
        } catch { markupsError = error.localizedDescription }
    }
}
