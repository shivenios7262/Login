import Foundation
import Observation

@Observable
@MainActor
final class HomeViewModel {
    private(set) var isSideMenuOpen = false

    private let authManager: AuthManager

    var agentName: String {
        guard let user = authManager.currentUser else { return String(localized: "Travel Agent") }
        let name = user.displayName
        return name.isEmpty ? (user.agencyName ?? String(localized: "Travel Agent")) : name
    }
    var agentEmail: String { authManager.currentUser?.agentEmail ?? "" }

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

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
