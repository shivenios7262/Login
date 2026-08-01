import Foundation
import Observation

// MARK: - Thin domain protocols

@MainActor
protocol BookingsProvider: AnyObject, Observable {
    var bookings: [AgentFlightBooking] { get }
    var isLoadingBookings: Bool { get }
    var bookingsError: String? { get }
    func fetchBookings() async
}

@MainActor
protocol ProfileProvider: AnyObject, Observable {
    var profile: AgentProfileData? { get }
    var isLoadingProfile: Bool { get }
    var profileError: String? { get }
    func fetchProfile() async
}

@MainActor
protocol StatementProvider: AnyObject, Observable {
    var statements: [StatementItem] { get }
    var isLoadingStatement: Bool { get }
    var statementError: String? { get }
    func fetchStatement() async
}

@MainActor
protocol MarkupsProvider: AnyObject, Observable {
    var markups: [MarkupItem] { get }
    var isLoadingMarkups: Bool { get }
    var markupsError: String? { get }
    func fetchMarkups() async
}

// MARK: - Combined alias (kept for legacy HomeViewModel conformance)

typealias B2BDataProvider = BookingsProvider & ProfileProvider & StatementProvider & MarkupsProvider

extension HomeViewModel: B2BDataProvider {}
