import Foundation
import Observation

// MARK: - Airport Model
// JSON shape: { "value": "Toronto", "label": "Toronto, Canada (YYZ)", "city": "YYZ, Lester B Pearson Intl" }

struct AirportItem: Hashable, Identifiable, Decodable {
    let value: String   // city name submitted to the API, e.g. "Toronto"
    let label: String   // display string shown in the dropdown, e.g. "Toronto, Canada (YYZ)"
    let city: String    // IATA + airport name, e.g. "YYZ, Lester B Pearson Intl"

    var id: String { label }
    var displayLabel: String { label }

    static let empty = AirportItem(value: "", label: "", city: "")
}

// MARK: - Enums

enum GroupFarePurpose: String, CaseIterable, Hashable {
    case adhoc     = "Adhoc"
    case wedding   = "Wedding"
    case leisure   = "Leisure"
    case religious = "Religious"
    case mice      = "MICE"
    case sports    = "Sports"
    case students  = "Students"
    case others    = "Others"
}

enum GroupFareJourney: String, CaseIterable, Hashable {
    case oneWay    = "One Way"
    case roundTrip = "Round Trip"
}

// MARK: - ViewModel

@Observable
@MainActor
final class GroupFareViewModel {

    // Pre-filled (read-only)
    let agentEmail: String
    let agentID: String
    let mobileNumber: String

    private let authManager: AuthManager

    // Form fields
    var purpose: GroupFarePurpose   = .adhoc
    var journey: GroupFareJourney   = .roundTrip
    var fromAirport: AirportItem    = .empty
    var toAirport: AirportItem      = .empty
    var departureDate: String       = ""
    var returnDate: String          = ""
    var noOfAdult: String           = ""
    var noOfChildren: String        = ""
    var noOfInfants: String         = ""
    var expectedFare: String        = ""
    var onwardFlightDetails: String = ""
    var returnFlightDetails: String = ""
    var remark: String              = ""

    // Derived strings for API submission
    var fromCity: String { fromAirport.value }
    var toCity: String   { toAirport.value }

    // Convenience
    var isRoundTrip: Bool { journey == .roundTrip }

    // Minimum departure = today + 15 days
    var minDepartureDate: Date {
        Calendar.current.date(byAdding: .day, value: 15, to: Date()) ?? Date()
    }

    // Airport data
    var airports: [AirportItem] = []
    var isLoadingAirports = false

    // UI state
    var isSubmitting: Bool            = false
    var isSubmitted: Bool             = false
    var submittedReferenceNo: String? = nil
    var alertMessage: String?         = nil
    var fieldErrors: [String: String] = [:]

    init(authManager: AuthManager) {
        self.authManager = authManager
        agentEmail   = authManager.currentUser?.agentEmail ?? ""
        agentID      = authManager.currentUser?.agentNo    ?? ""
        mobileNumber = authManager.currentUser?.mobileNo   ?? ""
    }

    // MARK: - Airport Loading

    private static var cacheURL: URL? {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first?
            .appendingPathComponent("airports.json")
    }

    /// Loads airports from disk cache first; fetches from network if cache is missing.
    func loadAirports() async {
        guard airports.isEmpty else { return }
        isLoadingAirports = true
        defer { isLoadingAirports = false }

        if let url = Self.cacheURL,
           let data = try? await readFile(at: url),
           let items = try? JSONDecoder().decode([AirportItem].self, from: data) {
            airports = items.filter { !$0.label.isEmpty }
            return
        }

        await fetchAndCacheAirports()
    }

    /// Clears the disk cache and re-fetches from the network.
    func refreshAirports() async {
        if let url = Self.cacheURL {
            try? FileManager.default.removeItem(at: url)
        }
        airports = []
        await loadAirports()
    }

    private nonisolated func readFile(at url: URL) async throws -> Data {
        try Data(contentsOf: url)
    }

    private func fetchAndCacheAirports() async {
        do {
            let url = URL(string: "https://cdn.ftd.travel/book/public/data/airports.json")!
            let (data, _) = try await URLSession.shared.data(from: url)
            let items = try JSONDecoder().decode([AirportItem].self, from: data)
            airports = items.filter { !$0.label.isEmpty }
            if let cacheURL = Self.cacheURL {
                try? data.write(to: cacheURL)
            }
        } catch {
            // silently fail — search fields show "No airport found" on empty list
        }
    }

    // MARK: - Validation

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd-MMM-yyyy"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let apiDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    /// Validates all fields, populates fieldErrors, and returns whether the form is valid.
    @discardableResult
    func validate() -> Bool {
        var errors: [String: String] = [:]

        // From / To city
        if fromAirport == .empty { errors["fromAirport"] = "Please select a city" }
        if toAirport == .empty   { errors["toAirport"]   = "Please select a city" }

        // Departure date (min: today + 15 days)
        let depTrimmed = departureDate.trimmingCharacters(in: .whitespaces)
        let minDate    = Calendar.current.startOfDay(for: minDepartureDate)
        if depTrimmed.isEmpty {
            errors["departureDate"] = "Required"
        } else if let date = Self.dateFormatter.date(from: depTrimmed) {
            if date < minDate {
                errors["departureDate"] = "Earliest: \(Self.dateFormatter.string(from: minDate))"
            }
        } else {
            errors["departureDate"] = "Use format: 17-May-2025"
        }

        // Return date (round trip only, must be ≥ departure)
        if isRoundTrip {
            let retTrimmed = returnDate.trimmingCharacters(in: .whitespaces)
            if retTrimmed.isEmpty {
                errors["returnDate"] = "Required"
            } else if let ret = Self.dateFormatter.date(from: retTrimmed) {
                if let dep = Self.dateFormatter.date(from: depTrimmed), ret < dep {
                    errors["returnDate"] = "Must be ≥ departure date"
                }
            } else {
                errors["returnDate"] = "Use format: 22-May-2025"
            }
        }

        // Adults (min 15)
        let adultTrimmed = noOfAdult.trimmingCharacters(in: .whitespaces)
        if adultTrimmed.isEmpty {
            errors["noOfAdult"] = "Required"
        } else if let n = Int(adultTrimmed) {
            if n < 15 { errors["noOfAdult"] = "Minimum 15 adults required" }
        } else {
            errors["noOfAdult"] = "Enter a valid number"
        }

        // Expected fare (mandatory, numbers only)
        let fare = expectedFare.trimmingCharacters(in: .whitespaces)
        if fare.isEmpty {
            errors["expectedFare"] = "Required"
        } else if Double(fare) == nil {
            errors["expectedFare"] = "Numbers only"
        }

        // Onward flight (always mandatory)
        if onwardFlightDetails.trimmingCharacters(in: .whitespaces).isEmpty {
            errors["onwardFlightDetails"] = "Required"
        }

        // Return flight (mandatory for round trip only)
        if isRoundTrip && returnFlightDetails.trimmingCharacters(in: .whitespaces).isEmpty {
            errors["returnFlightDetails"] = "Required"
        }

        // Remark (always mandatory)
        if remark.trimmingCharacters(in: .whitespaces).isEmpty {
            errors["remark"] = "Required"
        }

        fieldErrors = errors
        return errors.isEmpty
    }

    /// Clears validation errors for fields that are hidden when journey is One Way.
    func clearReturnErrors() {
        fieldErrors.removeValue(forKey: "returnDate")
        fieldErrors.removeValue(forKey: "returnFlightDetails")
    }

    func submit() async {
        guard validate() else { return }
        isSubmitting = true
        defer { isSubmitting = false }

        let depDate = Self.dateFormatter.date(from: departureDate.trimmingCharacters(in: .whitespaces))
            .map { Self.apiDateFormatter.string(from: $0) } ?? departureDate
        let retDate: String? = isRoundTrip
            ? Self.dateFormatter.date(from: returnDate.trimmingCharacters(in: .whitespaces))
                .map { Self.apiDateFormatter.string(from: $0) } ?? returnDate
            : nil

        let request = GroupFaresRequest(
            tripType: isRoundTrip ? "RoundTrip" : "OneWay",
            mobileNo: mobileNumber,
            fromCity: fromCity,
            toCity: toCity,
            departureDate: depDate,
            returnDate: retDate,
            numAdults: Int(noOfAdult.trimmingCharacters(in: .whitespaces)) ?? 0,
            numChild: Int(noOfChildren.trimmingCharacters(in: .whitespaces)) ?? 0,
            numInfant: Int(noOfInfants.trimmingCharacters(in: .whitespaces)) ?? 0,
            tripPurpose: purpose.rawValue,
            expFare: expectedFare.trimmingCharacters(in: .whitespaces),
            airlineDetailsOnward: onwardFlightDetails.trimmingCharacters(in: .whitespaces),
            airlineDetailsReturn: isRoundTrip ? returnFlightDetails.trimmingCharacters(in: .whitespaces) : nil,
            remarks: remark.trimmingCharacters(in: .whitespaces)
        )

        do {
            let refNo = try await authManager.submitGroupFaresRequest(request)
            submittedReferenceNo = refNo.isEmpty ? nil : refNo
            isSubmitted = true
        } catch let networkError as NetworkError {
            alertMessage = networkError.errorDescription
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    func reset() {
        purpose             = .adhoc
        journey             = .roundTrip
        fromAirport         = .empty
        toAirport           = .empty
        departureDate       = ""
        returnDate          = ""
        noOfAdult           = ""
        noOfChildren        = ""
        noOfInfants         = ""
        expectedFare        = ""
        onwardFlightDetails = ""
        returnFlightDetails = ""
        remark              = ""
        isSubmitting        = false
        isSubmitted         = false
        submittedReferenceNo = nil
        alertMessage        = nil
        fieldErrors         = [:]
    }
}
