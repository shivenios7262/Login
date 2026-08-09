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

    var agentEmail: String      { authManager.currentUser?.agentEmail  ?? "" }
    var agencyName: String      { authManager.currentUser?.agencyName  ?? "" }
    var mobileNo: String        { authManager.currentUser?.mobileNo    ?? "" }
    var agentNo: String         { authManager.currentUser?.agentNo     ?? "" }

    var agentLogoURL: URL? {
        guard let raw = authManager.currentUser?.agentLogo, !raw.isEmpty else { return nil }
        return URL(string: raw)
    }

    var creditBalanceLabel: String {
        guard let b = authManager.currentUser?.creditBalance, !b.isEmpty else { return "₹ Balance" }
        return "₹\(b)"
    }

    var bookingBalanceLabel: String {
        guard let b = authManager.currentUser?.bookingBalance, !b.isEmpty else { return "" }
        return "₹\(b)"
    }

    var creditBalanceDisplayLabel: String {
        guard let b = authManager.currentUser?.creditBalance, !b.isEmpty else { return "" }
        return "₹\(b)"
    }

    var registerDate: String {
        guard let raw = authManager.currentUser?.registerDate else { return "" }
        return Self.formatAPIDate(raw)
    }

    var lastLogin: String {
        guard let raw = authManager.currentUser?.lastLogin else { return "" }
        return Self.formatAPIDate(raw)
    }

    var lastBooking: String {
        guard let raw = authManager.currentUser?.lastBooking else { return "" }
        return Self.formatAPIDate(raw)
    }

    // Parses "yyyy-MM-dd HH:mm:ss" or "yyyy-MM-dd" into a readable date string.
    private static func formatAPIDate(_ raw: String) -> String {
        let inputFormats = ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd"]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for fmt in inputFormats {
            formatter.dateFormat = fmt
            if let date = formatter.date(from: raw) {
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                formatter.dateFormat = nil
                return formatter.string(from: date)
            }
        }
        return raw
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
