import Foundation
import Observation

@Observable
@MainActor
final class FTDHomeViewModel {
    private(set) var isSideMenuOpen = false
    var selectedTab: FTDHomeTab = .home
    var selectedOfferFilter: OfferFilter = .trending

    private let authManager: AuthManager

    // MARK: - Init

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - Derived agent info

    var agentName: String {
        guard let user = authManager.currentUser else { return String(localized: "Travel Agent") }
        let name = user.displayName
        return name.isEmpty ? (user.agencyName ?? String(localized: "Travel Agent")) : name
    }

    var agentEmail: String { authManager.currentUser?.agentEmail ?? "" }

    var creditBalanceLabel: String {
        guard let balance = authManager.currentUser?.creditBalance, !balance.isEmpty else {
            return "₹ Balance"
        }
        return "₹\(balance)"
    }

    // MARK: - Side menu

    func toggleSideMenu() { isSideMenuOpen.toggle() }
    func closeSideMenu()  { isSideMenuOpen = false }

    // MARK: - Session

    func checkAndRefreshTokenIfNeeded() async {
        await authManager.checkAndRefreshTokenIfNeeded()
    }

    func logout() {
        closeSideMenu()
        authManager.logout()
    }
}
