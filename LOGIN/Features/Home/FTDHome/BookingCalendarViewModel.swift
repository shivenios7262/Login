import Foundation
import Observation

// MARK: - View mode

enum CalendarViewMode: String, CaseIterable {
    case month = "month"
    case week  = "week"
    case day   = "day"
}

// MARK: - ViewModel

@Observable
@MainActor
final class BookingCalendarViewModel {

    var currentDate: Date         = Date()
    var viewMode: CalendarViewMode = .month
    var bookedDates: Set<String>  = []   // "yyyy-MM-dd" keys
    var isLoading: Bool           = false

    private let authManager: AuthManager
    private let cal = Calendar.current
    private let dateFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - Navigation

    func goNext() {
        switch viewMode {
        case .month: advance(.month,      by:  1)
        case .week:  advance(.weekOfYear, by:  1)
        case .day:   advance(.day,        by:  1)
        }
    }

    func goPrev() {
        switch viewMode {
        case .month: advance(.month,      by: -1)
        case .week:  advance(.weekOfYear, by: -1)
        case .day:   advance(.day,        by: -1)
        }
    }

    func goToToday() { currentDate = Date() }

    // MARK: - Header title

    var headerTitle: String {
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US_POSIX")
        switch viewMode {
        case .month:
            fmt.dateFormat = "MMMM yyyy"
            return fmt.string(from: currentDate)
        case .week:
            let ws = weekStart(for: currentDate)
            let we = cal.date(byAdding: .day, value: 6, to: ws) ?? ws
            fmt.dateFormat = "MMM d"
            let s = fmt.string(from: ws)
            fmt.dateFormat = "d, yyyy"
            return "\(s) – \(fmt.string(from: we))"
        case .day:
            fmt.dateFormat = "EEEE, MMM d yyyy"
            return fmt.string(from: currentDate)
        }
    }

    // MARK: - Month grid (nil = empty padding cell)

    var monthGridDays: [Date?] {
        guard
            let monthStart = cal.date(from: cal.dateComponents([.year, .month], from: currentDate)),
            let range      = cal.range(of: .day, in: .month, for: monthStart)
        else { return [] }

        let leadPad = cal.component(.weekday, from: monthStart) - 1  // 0 = Sun
        var days: [Date?] = Array(repeating: nil, count: leadPad)

        for day in 1...range.count {
            days.append(cal.date(byAdding: .day, value: day - 1, to: monthStart))
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    // MARK: - Week days

    var weekDays: [Date] {
        let ws = weekStart(for: currentDate)
        return (0..<7).compactMap { cal.date(byAdding: .day, value: $0, to: ws) }
    }

    // MARK: - Helpers

    func isToday(_ date: Date) -> Bool { cal.isDateInToday(date) }

    func isCurrentMonth(_ date: Date) -> Bool {
        cal.component(.month, from: date) == cal.component(.month, from: currentDate)
    }

    func hasBooking(on date: Date) -> Bool {
        bookedDates.contains(dateFmt.string(from: date))
    }

    func dayNumber(_ date: Date) -> String {
        String(cal.component(.day, from: date))
    }

    func shortWeekday(_ date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "EEE"
        return f.string(from: date)
    }

    // MARK: - Data fetch

    func fetchBookedDates() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }

        // Fetch a 3-month window centred on the current date
        let start = cal.date(byAdding: .month, value: -1, to: currentDate) ?? currentDate
        let end   = cal.date(byAdding: .month, value:  2, to: currentDate) ?? currentDate

        let request = AgentBookingsRequest(
            searchType: 1,
            fromDate: dateFmt.string(from: start),
            toDate:   dateFmt.string(from: end)
        )

        do {
            let response = try await authManager.fetchBookings(request: request)
            let dates = (response.data?.flightBookingSummary ?? [])
                .compactMap { $0.departureDate?.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            bookedDates.formUnion(dates)
        } catch {
            // Calendar still functions without booking data; fail silently
        }
    }

    // MARK: - Private

    private func advance(_ component: Calendar.Component, by value: Int) {
        currentDate = cal.date(byAdding: component, value: value, to: currentDate) ?? currentDate
    }

    private func weekStart(for date: Date) -> Date {
        var comps = cal.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        comps.weekday = 1
        return cal.date(from: comps) ?? date
    }
}
