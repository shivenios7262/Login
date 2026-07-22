import Foundation
import Observation

@Observable
@MainActor
final class FTDHomeViewModel {
    private(set) var isSideMenuOpen = false
    var selectedTab: FTDHomeTab = .home
    var selectedOfferFilter: OfferFilter = .trending

    private let authManager: AuthManager

    // MARK: - Derived agent info

    var agentName: String {
        guard let user = authManager.currentUser else { return String(localized: "Travel Agent") }
        let name = user.displayName
        return name.isEmpty ? (user.agencyName ?? String(localized: "Travel Agent")) : name
    }

    var agentEmail: String { authManager.currentUser?.agentEmail ?? "" }

    /// Shows live creditBalance from the server if available, falls back to a label.
    var creditBalanceLabel: String {
        guard let balance = authManager.currentUser?.creditBalance, !balance.isEmpty else {
            return "₹ Balance"
        }
        return "₹\(balance)"
    }

    // MARK: - Init

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - Intent handlers

    func toggleSideMenu() { isSideMenuOpen.toggle() }
    func closeSideMenu()   { isSideMenuOpen = false }

    func checkAndRefreshTokenIfNeeded() async {
        await authManager.checkAndRefreshTokenIfNeeded()
    }

    func logout() {
        closeSideMenu()
        authManager.logout()
    }
}
