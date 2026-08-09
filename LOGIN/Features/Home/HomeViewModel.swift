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

    // MARK: - Sheet navigation

    var showBookings  = false
    var showProfile   = false
    var showStatement = false
    var showMarkups   = false

    // MARK: - Bookings state

    private(set) var bookings: [AgentFlightBooking] = []
    private(set) var isLoadingBookings = false
    private(set) var bookingsError: String? = nil

    // MARK: - Profile state

    private(set) var profile: AgentProfileData? = nil
    private(set) var isLoadingProfile = false
    private(set) var profileError: String? = nil

    // MARK: - Statement state

    private(set) var statements: [StatementItem] = []
    private(set) var isLoadingStatement = false
    private(set) var statementError: String? = nil

    // MARK: - Markups state

    private(set) var markups: [MarkupItem] = []
    private(set) var isLoadingMarkups = false
    private(set) var markupsError: String? = nil

    // MARK: - Init

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - Menu

    func toggleSideMenu() { isSideMenuOpen.toggle() }
    func closeSideMenu()  { isSideMenuOpen = false }

    func openBookings() {
        closeSideMenu()
        showBookings = true
    }

    func openProfile() {
        closeSideMenu()
        showProfile = true
    }

    func openStatement() {
        closeSideMenu()
        showStatement = true
    }

    func openMarkups() {
        closeSideMenu()
        showMarkups = true
    }

    func checkAndRefreshTokenIfNeeded() async {
        await authManager.checkAndRefreshTokenIfNeeded()
    }

    func logout() {
        closeSideMenu()
        authManager.logout()
    }

    // MARK: - Fetch: Bookings

    func fetchBookings() async {
        isLoadingBookings = true
        bookingsError = nil
        defer { isLoadingBookings = false }

        let today = Date()
        let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: today) ?? today
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"

        let request = AgentBookingsRequest(
            searchType: 1,
            fromDate: fmt.string(from: fromDate),
            toDate: fmt.string(from: today)
        )
        do {
            let response = try await authManager.fetchBookings(request: request)
            if response.status {
                bookings = response.data?.flightBookingSummary ?? []
            } else {
                bookingsError = response.message ?? String(localized: "Failed to load bookings.")
            }
        } catch let error as NetworkError {
            bookingsError = error.errorDescription
        } catch {
            bookingsError = error.localizedDescription
        }
    }

    // MARK: - Fetch: Profile

    func fetchProfile() async {
        isLoadingProfile = true
        profileError = nil
        defer { isLoadingProfile = false }
        do {
            let response = try await authManager.fetchProfile()
            if response.status {
                profile = response.data
            } else {
                profileError = response.message ?? String(localized: "Failed to load profile.")
            }
        } catch let error as NetworkError {
            profileError = error.errorDescription
        } catch {
            profileError = error.localizedDescription
        }
    }

    // MARK: - Fetch: Statement

    func fetchStatement() async {
        isLoadingStatement = true
        statementError = nil
        defer { isLoadingStatement = false }

        let today = Date()
        let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: today) ?? today
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"

        let request = AgencyStatementRequest(
            fromDate: fmt.string(from: fromDate),
            toDate: fmt.string(from: today)
        )
        do {
            let response = try await authManager.fetchStatement(request: request)
            if response.status {
                statements = response.data?.depositStatement ?? []
            } else {
                statementError = response.message ?? String(localized: "Failed to load statement.")
            }
        } catch let error as NetworkError {
            statementError = error.errorDescription
        } catch {
            statementError = error.localizedDescription
        }
    }

    // MARK: - Fetch: Markups

    func fetchMarkups() async {
        isLoadingMarkups = true
        markupsError = nil
        defer { isLoadingMarkups = false }
        do {
            let response = try await authManager.fetchMarkups()
            if response.status {
                markups = response.data ?? []
            } else {
                markupsError = response.message ?? String(localized: "Failed to load markups.")
            }
        } catch let error as NetworkError {
            markupsError = error.errorDescription
        } catch {
            markupsError = error.localizedDescription
        }
    }
}
