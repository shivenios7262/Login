import Foundation
import Observation

// MARK: - Tab

enum BookingTab: String, CaseIterable, Identifiable {
    case flight    = "Flight"
    case bus       = "Bus"
    case cab       = "Cab"
    case hotel     = "Hotel"
    case insurance = "Insurance"
    case visa      = "Visa"
    case esim      = "eSIM"

    var id: String { rawValue }

    var searchType: Int {
        switch self {
        case .flight:    return 1
        case .bus:       return 2
        case .cab:       return 3
        case .hotel:     return 4
        case .insurance: return 5
        case .visa:      return 6
        case .esim:      return 7
        }
    }

    var icon: String {
        switch self {
        case .flight:    return "airplane"
        case .bus:       return "bus"
        case .cab:       return "car"
        case .hotel:     return "building.2"
        case .insurance: return "shield"
        case .visa:      return "doc.text"
        case .esim:      return "simcard"
        }
    }
}

// MARK: - ViewModel

@Observable
@MainActor
final class BookingsViewModel: BookingsProvider {

    // MARK: - Protocol

    var bookings: [AgentFlightBooking]  { flightBookings }
    var isLoadingBookings: Bool         { isLoading }
    var bookingsError: String?          { error }

    // MARK: - Tab

    var selectedTab: BookingTab = .flight

    // MARK: - Results

    private(set) var flightBookings: [AgentFlightBooking] = []
    private(set) var isLoading  = false
    private(set) var error: String? = nil

    // MARK: - Filters: Flight

    var flightFromDate  = ""
    var flightToDate    = ""
    var flightPNR       = ""
    var flightStatus    = ""
    var flightAirline   = ""
    var flightName      = ""

    // MARK: - Filters: Bus

    var busFromDate     = ""
    var busToDate       = ""
    var busDepartDate   = ""
    var busBkgDate      = ""
    var busRefNo        = ""
    var busPassName     = ""
    var busStatus       = ""

    // MARK: - Filters: Cab

    var cabFromDate     = ""
    var cabToDate       = ""
    var cabPNR          = ""
    var cabDepartDate   = ""
    var cabBkgDate      = ""
    var cabStatus       = ""
    var cabName         = ""

    // MARK: - Filters: Hotel

    var hotelPNR        = ""
    var hotelRefNo      = ""
    var hotelCheckIn    = ""
    var hotelCheckOut   = ""
    var hotelStatus     = ""

    // MARK: - Filters: Insurance

    var insReference    = ""
    var insOnwardDate   = ""
    var insReturnDate   = ""
    var insCountry      = ""
    var insStatus       = ""
    var insType         = ""

    // MARK: - Filters: Visa

    var visaReference   = ""
    var visaOnwardDate  = ""
    var visaReturnDate  = ""
    var visaCountry     = ""

    // MARK: - Filters: eSIM

    var esimReference   = ""
    var esimFromDate    = ""
    var esimToDate      = ""

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: - Protocol entry-point

    func fetchBookings() async { await search() }

    // MARK: - Search

    func search() async {
        isLoading = true
        error     = nil
        defer { isLoading = false }

        let request = buildRequest()
        do {
            let response = try await authManager.fetchBookings(request: request)
            if selectedTab == .flight {
                flightBookings = response.status ? (response.data?.flightBookingSummary ?? []) : []
            } else {
                flightBookings = []
            }
            if !response.status {
                error = response.message ?? String(localized: "Failed to load bookings.")
            }
        } catch let e as NetworkError { error = e.errorDescription
        } catch { self.error = error.localizedDescription }
    }

    func resetFilters() {
        switch selectedTab {
        case .flight:
            flightFromDate = ""; flightToDate = ""; flightPNR = ""
            flightStatus   = ""; flightAirline = ""; flightName = ""
        case .bus:
            busFromDate = ""; busToDate = ""; busDepartDate = ""
            busBkgDate  = ""; busRefNo  = ""; busPassName   = ""; busStatus = ""
        case .cab:
            cabFromDate = ""; cabToDate = ""; cabPNR = ""; cabDepartDate = ""
            cabBkgDate  = ""; cabStatus = ""; cabName = ""
        case .hotel:
            hotelPNR = ""; hotelRefNo = ""; hotelCheckIn = ""
            hotelCheckOut = ""; hotelStatus = ""
        case .insurance:
            insReference = ""; insOnwardDate = ""; insReturnDate = ""
            insCountry   = ""; insStatus = ""; insType = ""
        case .visa:
            visaReference = ""; visaOnwardDate = ""; visaReturnDate = ""; visaCountry = ""
        case .esim:
            esimReference = ""; esimFromDate = ""; esimToDate = ""
        }
    }

    // MARK: - Request builder

    private func buildRequest() -> AgentBookingsRequest {
        switch selectedTab {
        case .flight:
            return AgentBookingsRequest(
                searchType:  1,
                firstName:   flightName.bnil,
                pnr:         flightPNR.bnil,
                status:      flightStatus.bnil,
                fromDate:    flightFromDate.bnil,
                toDate:      flightToDate.bnil,
                airline:     flightAirline.bnil
            )
        case .bus:
            return AgentBookingsRequest(
                searchType:           2,
                bBookingStatus:       busStatus.bnil,
                bFromDate:            busFromDate.bnil,
                bToDate:              busToDate.bnil,
                bBookingDate:         busBkgDate.bnil,
                bUniqueRefNo:         busRefNo.bnil,
                bPassName:            busPassName.bnil,
                bDepartDate:          busDepartDate.bnil
            )
        case .cab:
            return AgentBookingsRequest(
                searchType:   3,
                cPnr:         cabPNR.bnil,
                cFromDate:    cabFromDate.bnil,
                cToDate:      cabToDate.bnil,
                cDepartDate:  cabDepartDate.bnil,
                cStatus:      cabStatus.bnil,
                cFirstName:   cabName.bnil,
                cBookingDate: cabBkgDate.bnil
            )
        case .hotel:
            return AgentBookingsRequest(
                searchType:        4,
                pnrHotel:          hotelPNR.bnil,
                uniqueRefNoHotel:  hotelRefNo.bnil,
                checkInDate:       hotelCheckIn.bnil,
                checkOutDate:      hotelCheckOut.bnil,
                hotelStatus:       hotelStatus.bnil
            )
        case .insurance:
            return AgentBookingsRequest(
                searchType:          5,
                referenceInsurance:  insReference.bnil,
                onwardDate:          insOnwardDate.bnil,
                returnDate:          insReturnDate.bnil,
                countryName:         insCountry.bnil,
                insuranceStatus:     insStatus.bnil,
                insuranceType:       insType.bnil
            )
        case .visa:
            return AgentBookingsRequest(
                searchType:      6,
                referenceVisa:   visaReference.bnil,
                onwardDateVisa:  visaOnwardDate.bnil,
                returnDateVisa:  visaReturnDate.bnil,
                countryNameVisa: visaCountry.bnil
            )
        case .esim:
            return AgentBookingsRequest(
                searchType:    7,
                referenceEsim: esimReference.bnil,
                esimFromDate:  esimFromDate.bnil,
                esimToDate:    esimToDate.bnil
            )
        }
    }
}

private extension String {
    var bnil: String? { isEmpty ? nil : self }
}
