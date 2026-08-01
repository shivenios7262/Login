import Foundation
import Observation

@Observable
@MainActor
final class BookingsViewModel: BookingsProvider {
    private(set) var bookings: [AgentFlightBooking] = []
    private(set) var isLoadingBookings = false
    private(set) var bookingsError: String? = nil

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func fetchBookings() async {
        isLoadingBookings = true
        bookingsError = nil
        defer { isLoadingBookings = false }

        let today = Date()
        let fromDate = Calendar.current.date(byAdding: .day, value: -30, to: today) ?? today
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"

        let request = AgentBookingsRequest(
            searchType: 1,
            fromDate: fmt.string(from: fromDate),
            toDate: fmt.string(from: today)
        )
        do {
            let response = try await authManager.fetchBookings(request: request)
            bookings = response.status ? (response.data?.flightBookingSummary ?? []) : []
            if !response.status {
                bookingsError = response.message ?? String(localized: "Failed to load bookings.")
            }
        } catch let e as NetworkError { bookingsError = e.errorDescription
        } catch { bookingsError = error.localizedDescription }
    }
}
