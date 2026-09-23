import Foundation
import Observation

// MARK: - Tab

enum RefundTab: String, CaseIterable, Identifiable {
    case flight    = "Flight"
    case bus       = "Bus"
    case cab       = "Cab"
    case hotel     = "Hotel"
    case insurance = "Insurance"
    case visa      = "Visa"
    case esim      = "eSIM"

    var id: String { rawValue }

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

    // API search_type values (confirmed from server-side docs)
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

    // Raw API values; Visa has no status filter.
    // API filter values differ per vertical
    var refundStatusOptions: [String] {
        switch self {
        case .visa:                          return []
        case .bus, .cab, .insurance, .esim: return ["", "1", "2"]
        default:                             return ["", "0", "1"]
        }
    }

    // Maps the API filter value → display label, per tab
    func refundStatusLabel(for value: String) -> String {
        switch self {
        case .bus, .cab, .insurance, .esim:
            switch value {
            case "1": return "Under Process"
            case "2": return "Refunded"
            default:  return "Select Status"
            }
        default:
            switch value {
            case "0": return "Under Process"
            case "1": return "Refunded"
            default:  return "Select Status"
            }
        }
    }
}

// MARK: - Record

struct RefundRecord: Identifiable {
    let id = UUID()
    var bookingRef: String
    var secondaryRef: String?
    var passengerName: String?
    var pnr: String?
    var policyNo: String?
    var cancellationDate: String?
    var refundDate: String?
    var cancelType: String?
    var amount: String?
    var agentNet: String?
    var status: String?
    var carrierName: String?
    var fareType: String?
    var passengerCount: Int = 0
    var passengers: [RefundPassenger] = []
    var passengerNames: [String] = []
}

// MARK: - ViewModel

@Observable
@MainActor
final class RefundViewModel {

    // MARK: Tab
    var selectedTab: RefundTab = .flight

    // MARK: Auto-load key — changing this triggers .task(id:) in the view
    var autoLoadKey: String = RefundTab.flight.rawValue

    // MARK: Booking date range (fromdate / todate per API)
    var cancelFromDate: String
    var cancelToDate   = ""

    // MARK: Refund date range (rfromdate / rtodate per API)
    var refundFromDate = ""
    var refundToDate   = ""

    // MARK: Common filters
    var bookingId    = ""
    var refundStatus = ""

    // MARK: Flight / Bus / Cab / Hotel
    var pnr = ""

    // MARK: Insurance
    var policyNo = ""

    // MARK: Results
    private(set) var records: [RefundRecord] = []
    private(set) var isLoading  = false
    private(set) var error: String? = nil
    private(set) var hasSearched = false

    // MARK: Table controls
    var searchQuery  = ""
    var totalEntries = 0

    // MARK: Export
    var showExportSheet = false
    var exportURL: URL? = nil

    // MARK: Computed

    var filteredRecords: [RefundRecord] {
        guard !searchQuery.isEmpty else { return records }
        let q = searchQuery.lowercased()
        return records.filter {
            $0.bookingRef.lowercased().contains(q) ||
            ($0.secondaryRef?.lowercased().contains(q) ?? false) ||
            ($0.passengerName?.lowercased().contains(q) ?? false) ||
            ($0.pnr?.lowercased().contains(q) ?? false) ||
            ($0.policyNo?.lowercased().contains(q) ?? false) ||
            ($0.status?.lowercased().contains(q) ?? false)
        }
    }

    var hasPNRField:    Bool { [.flight, .bus, .cab, .hotel].contains(selectedTab) }
    var hasPolicyField: Bool { selectedTab == .insurance }
    var hasStatusField: Bool { selectedTab != .visa }

    // MARK: Private

    private let authManager: AuthManager

    private static let apiFmt: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    private static let amountFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.groupingSeparator = ","
        f.locale = Locale(identifier: "en_US_POSIX")
        return f
    }()

    static func oneMonthAgo() -> String {
        let date = Calendar.current.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        return apiFmt.string(from: date)
    }

    init(authManager: AuthManager) {
        self.authManager  = authManager
        self.cancelFromDate = Self.oneMonthAgo()
    }

    // MARK: Tab Switch

    func switchTab(_ tab: RefundTab) {
        guard tab != selectedTab else { return }
        selectedTab = tab
        resetFilters()
        autoLoadKey = tab.rawValue + UUID().uuidString  // change key → triggers .task reload
    }

    // MARK: Search

    func search() async {
        isLoading   = true
        error       = nil
        hasSearched = true
        defer { isLoading = false }

        let from     = cancelFromDate.isEmpty ? nil : cancelFromDate
        let to       = cancelToDate.isEmpty   ? nil : cancelToDate
        let rFrom    = refundFromDate.isEmpty  ? nil : refundFromDate
        let rTo      = refundToDate.isEmpty    ? nil : refundToDate
        let bId      = bookingId.isEmpty       ? nil : bookingId
        let pnrVal   = pnr.isEmpty             ? nil : pnr
        let polVal   = policyNo.isEmpty        ? nil : policyNo
        let statusVal = refundStatus.isEmpty   ? nil : refundStatus

        let request: AgentRefundsRequest
        switch selectedTab {
        case .flight:
            request = AgentRefundsRequest(searchType: selectedTab.searchType,
                fromDate: from, toDate: to, rFromDate: rFrom, rToDate: rTo,
                fPnr: pnrVal, bookingId: bId, fRefunded: statusVal)
        case .bus:
            request = AgentRefundsRequest(searchType: selectedTab.searchType,
                bFromDate: from, bToDate: to, bRFromDate: rFrom, bRToDate: rTo,
                bBookingId: bId, bPnr: pnrVal, bRefundStatus: statusVal)
        case .cab:
            request = AgentRefundsRequest(searchType: selectedTab.searchType,
                cFromDate: from, cToDate: to, cRFromDate: rFrom, cRToDate: rTo,
                cBookingId: bId, cPnr: pnrVal, cRefunded: statusVal)
        case .hotel:
            request = AgentRefundsRequest(searchType: selectedTab.searchType,
                hFromDate: from, hToDate: to, hRFromDate: rFrom, hRToDate: rTo,
                hBookingId: bId, hPnr: pnrVal, hRefundStatus: statusVal)
        case .insurance:
            request = AgentRefundsRequest(searchType: selectedTab.searchType,
                iFromDate: from, iToDate: to, iRFromDate: rFrom, iRToDate: rTo,
                iPolicy: polVal, iBookingId: bId, iRefundStatus: statusVal)
        case .visa:
            request = AgentRefundsRequest(searchType: selectedTab.searchType,
                vFromDate: from, vToDate: to, vRFromDate: rFrom, vRToDate: rTo,
                vBookingId: bId)
        case .esim:
            request = AgentRefundsRequest(searchType: selectedTab.searchType,
                eFromDate: from, eToDate: to, eRFromDate: rFrom, eRToDate: rTo,
                eBookingId: bId, eRefundStatus: statusVal)
        }

        do {
            let response = try await authManager.fetchRefunds(request: request)
            if response.status {
                let data = response.data
                switch selectedTab {
                case .flight:    records = mapBookings(data?.flightBookings)
                case .bus:       records = mapBusBookings(data?.busBookings)
                case .cab:       records = mapCabBookings(data?.cabBookings)
                case .hotel:     records = mapHotelBookings(data?.hotelBookings)
                case .insurance: records = mapInsuranceBookings(data?.insuranceBookings)
                case .visa:      records = mapVisaBookings(data?.visaBookings)
                case .esim:      records = mapEsimBookings(data?.esimBookings)
                }
                totalEntries = records.count
            } else {
                records      = []
                totalEntries = 0
                error = response.message ?? String(localized: "Failed to load refunds.")
            }
        } catch is CancellationError {
            // Task cancelled by tab switch; the next request will update state.
        } catch let networkError as NetworkError {
            records      = []
            totalEntries = 0
            error = networkError.errorDescription
        } catch {
            records      = []
            totalEntries = 0
            self.error = error.localizedDescription
        }
    }

    // MARK: Export

    func triggerExport() {
        guard !filteredRecords.isEmpty else {
            error = String(localized: "No records to export.")
            return
        }
        exportURL = buildCSV()
        if exportURL != nil { showExportSheet = true }
    }

    // MARK: Filters

    func resetFilters() {
        cancelFromDate = Self.oneMonthAgo()
        cancelToDate   = ""
        refundFromDate = ""; refundToDate  = ""
        bookingId      = ""; refundStatus  = ""
        pnr            = ""; policyNo      = ""
        searchQuery    = ""
    }

    // MARK: Mapping

    private func mapBookings(_ bookings: [FlightRefundBooking]?) -> [RefundRecord] {
        guard let bookings else { return [] }
        return bookings.map { booking in
            let passengers = booking.passengers ?? []
            let firstPax   = passengers.first
            let uniquePnr = passengers
                .compactMap { $0.pnr?.trimmingCharacters(in: .whitespaces) }
                .first(where: { !$0.isEmpty })
            let names: String? = {
                let ns = passengers
                    .compactMap { $0.name?.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                guard !ns.isEmpty else { return nil }
                return ns.count == 1 ? ns[0] : "\(ns[0]) + \(ns.count - 1)"
            }()
            let amountStr: String? = {
                guard let amt = booking.refundAmount, amt > 0 else { return nil }
                return Self.amountFormatter.string(from: NSNumber(value: amt))
            }()
            let agentNetStr: String? = {
                guard let net = booking.agentNet,
                      let val = Double(net), val > 0 else { return nil }
                return Self.amountFormatter.string(from: NSNumber(value: val))
            }()
            return RefundRecord(
                bookingRef:       booking.uniqueRefNo ?? "",
                secondaryRef:     uniquePnr,
                passengerName:    names,
                pnr:              uniquePnr,
                policyNo:         nil,
                cancellationDate: firstPax?.cancelDate,
                refundDate:       firstPax?.refundDate,
                cancelType:       firstPax?.cancelType,
                amount:           amountStr,
                agentNet:         agentNetStr,
                status:           booking.status,
                carrierName:      booking.validatingCarrierName,
                fareType:         booking.fareType,
                passengerCount:   passengers.count,
                passengers:       passengers
            )
        }
    }

    private func mapEsimBookings(_ bookings: [EsimRefundBooking]?) -> [RefundRecord] {
        guard let bookings else { return [] }
        return bookings.map { booking in
            let passengers = booking.passengers ?? []
            let firstPax   = passengers.first
            let names: String? = {
                let ns = passengers
                    .compactMap { $0.name?.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                guard !ns.isEmpty else { return nil }
                return ns.count == 1 ? ns[0] : "\(ns[0]) + \(ns.count - 1)"
            }()
            let totalAmount: Double = passengers.compactMap {
                $0.refundAmount.flatMap { Double($0) }
            }.reduce(0, +)
            let amountStr: String? = totalAmount > 0
                ? Self.amountFormatter.string(from: NSNumber(value: totalAmount))
                : nil
            let agentNetStr: String? = {
                guard let val = booking.agentNet, val > 0 else { return nil }
                return Self.amountFormatter.string(from: NSNumber(value: val))
            }()
            // eSIM: "1" = Under Process, "2" = Refunded
            let statusValues = passengers.compactMap { $0.refundStatus }
            let normalizedStatus: String? = statusValues.isEmpty ? nil
                : statusValues.allSatisfy({ $0 == "2" }) ? "Refunded" : "Under Process"
            return RefundRecord(
                bookingRef:       booking.uniqueRefNo ?? "",
                secondaryRef:     nil,
                passengerName:    names,
                pnr:              nil,
                policyNo:         nil,
                cancellationDate: firstPax?.cancelDate,
                refundDate:       firstPax?.refundDate,
                cancelType:       nil,
                amount:           amountStr,
                agentNet:         agentNetStr,
                status:           normalizedStatus,
                carrierName:      nil,
                fareType:         nil,
                passengerCount:   passengers.count,
                passengers:       [],
                passengerNames:   passengers.compactMap { $0.name?.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            )
        }
    }

    private func mapVisaBookings(_ bookings: [VisaRefundBooking]?) -> [RefundRecord] {
        guard let bookings else { return [] }
        return bookings.map { booking in
            let passengers = booking.passengers ?? []
            let firstPax   = passengers.first
            let names: String? = {
                let ns = passengers
                    .compactMap { $0.name?.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                guard !ns.isEmpty else { return nil }
                return ns.count == 1 ? ns[0] : "\(ns[0]) + \(ns.count - 1)"
            }()
            let totalAmount: Double = passengers.compactMap {
                $0.refundAmount.flatMap { Double($0) }
            }.reduce(0, +)
            let amountStr: String? = totalAmount > 0
                ? Self.amountFormatter.string(from: NSNumber(value: totalAmount))
                : nil
            // Visa is always refunded
            let normalizedStatus: String? = "Refunded"
            return RefundRecord(
                bookingRef:       booking.referenceNo ?? "",
                secondaryRef:     nil,
                passengerName:    names,
                pnr:              nil,
                policyNo:         nil,
                cancellationDate: firstPax?.chargeDate,
                refundDate:       firstPax?.reverseDate,
                cancelType:       nil,
                amount:           amountStr,
                agentNet:         nil,
                status:           normalizedStatus,
                carrierName:      nil,
                fareType:         nil,
                passengerCount:   passengers.count,
                passengers:       [],
                passengerNames:   passengers.compactMap { $0.name?.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            )
        }
    }

    private func mapInsuranceBookings(_ bookings: [InsuranceRefundBooking]?) -> [RefundRecord] {
        guard let bookings else { return [] }
        return bookings.map { booking in
            let passengers = booking.passengers ?? []
            let firstPax   = passengers.first
            let names: String? = {
                let ns = passengers
                    .compactMap { $0.name?.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                guard !ns.isEmpty else { return nil }
                return ns.count == 1 ? ns[0] : "\(ns[0]) + \(ns.count - 1)"
            }()
            // Sum refund amounts across all passengers
            let totalAmount: Double = passengers.compactMap {
                $0.refundAmount.flatMap { Double($0) }
            }.reduce(0, +)
            let amountStr: String? = totalAmount > 0
                ? Self.amountFormatter.string(from: NSNumber(value: totalAmount))
                : nil
            let agentNetStr: String? = {
                guard let val = booking.agentNet, val > 0 else { return nil }
                return Self.amountFormatter.string(from: NSNumber(value: val))
            }()
            // Insurance: "1" = Under Process, "2" = Refunded
            let statusValues = passengers.compactMap { $0.status }
            let normalizedStatus: String? = statusValues.isEmpty ? nil
                : statusValues.allSatisfy({ $0 == "2" }) ? "Refunded" : "Under Process"
            return RefundRecord(
                bookingRef:       booking.referenceNo ?? "",
                secondaryRef:     firstPax?.policyNo,
                passengerName:    names,
                pnr:              nil,
                policyNo:         firstPax?.policyNo,
                cancellationDate: firstPax?.cancelDate,
                refundDate:       firstPax?.refundDate,
                cancelType:       nil,
                amount:           amountStr,
                agentNet:         agentNetStr,
                status:           normalizedStatus,
                carrierName:      nil,
                fareType:         nil,
                passengerCount:   passengers.count,
                passengers:       [],
                passengerNames:   passengers.compactMap { $0.name?.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }
            )
        }
    }

    private func mapHotelBookings(_ bookings: [HotelRefundBooking]?) -> [RefundRecord] {
        guard let bookings else { return [] }
        return bookings.map { booking in
            let passengers = booking.passengers ?? []
            let names: String? = {
                let ns = passengers
                    .compactMap { $0.name?.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                guard !ns.isEmpty else { return nil }
                return ns.count == 1 ? ns[0] : "\(ns[0]) + \(ns.count - 1)"
            }()
            let amountStr: String? = {
                guard let raw = booking.refundAmount,
                      let val = Double(raw), val > 0 else { return nil }
                return Self.amountFormatter.string(from: NSNumber(value: val))
            }()
            let agentNetStr: String? = {
                guard let raw = booking.agentNet,
                      let val = Double(raw), val > 0 else { return nil }
                return Self.amountFormatter.string(from: NSNumber(value: val))
            }()
            // Hotel API: "0" = Under Process, "1" = Refunded
            let normalizedStatus: String? = {
                switch booking.status {
                case "0":  return "Under Process"
                case "1":  return "Refunded"
                default:   return booking.status
                }
            }()
            return RefundRecord(
                bookingRef:       booking.uniqueRefNo ?? "",
                secondaryRef:     booking.bookingId,
                passengerName:    names,
                pnr:              booking.bookingId,
                policyNo:         nil,
                cancellationDate: booking.cancelDate,
                refundDate:       booking.refundDate,
                cancelType:       nil,
                amount:           amountStr,
                agentNet:         agentNetStr,
                status:           normalizedStatus,
                carrierName:      nil,
                fareType:         nil,
                passengerCount:   passengers.count,
                passengers:       passengers
            )
        }
    }

    private func mapCabBookings(_ bookings: [CabRefundBooking]?) -> [RefundRecord] {
        guard let bookings else { return [] }
        return bookings.map { booking in
            let amountStr: String? = {
                guard let amt = booking.refundAmount, amt > 0 else { return nil }
                return Self.amountFormatter.string(from: NSNumber(value: amt))
            }()
            let agentNetStr: String? = {
                guard let val = booking.agentNet, val > 0 else { return nil }
                return Self.amountFormatter.string(from: NSNumber(value: val))
            }()
            // Cab API: "1" = Under Process, "2" = Refunded
            let normalizedStatus: String? = {
                switch booking.status {
                case "1":  return "Under Process"
                case "2":  return "Refunded"
                default:   return nil
                }
            }()
            return RefundRecord(
                bookingRef:       booking.uniqueRefNo ?? "",
                secondaryRef:     booking.bookingId,
                passengerName:    booking.userName,
                pnr:              booking.bookingId,
                policyNo:         nil,
                cancellationDate: booking.cancelDate,
                refundDate:       booking.refundDate,
                cancelType:       nil,
                amount:           amountStr,
                agentNet:         agentNetStr,
                status:           normalizedStatus,
                carrierName:      nil,
                fareType:         nil,
                passengerCount:   0,
                passengers:       []
            )
        }
    }

    private func mapBusBookings(_ bookings: [BusRefundBooking]?) -> [RefundRecord] {
        guard let bookings else { return [] }
        return bookings.map { booking in
            let passengers = booking.passengers ?? []
            let names: String? = {
                let ns = passengers
                    .compactMap { $0.name?.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                guard !ns.isEmpty else { return nil }
                return ns.count == 1 ? ns[0] : "\(ns[0]) + \(ns.count - 1)"
            }()
            let amountStr: String? = booking.refundAmount.flatMap {
                Self.amountFormatter.string(from: NSNumber(value: $0))
            }
            let agentNetStr: String? = booking.agentNetPrice.flatMap {
                Double($0).flatMap { Self.amountFormatter.string(from: NSNumber(value: $0)) }
            }
            // Bus API: "1" = Under Process, "2" = Refunded
            let normalizedStatus: String? = {
                switch booking.status {
                case "1":  return "Under Process"
                case "2":  return "Refunded"
                default:   return booking.status
                }
            }()
            return RefundRecord(
                bookingRef:       booking.uniqueRefNo ?? "",
                secondaryRef:     booking.bookingReferenceNo,
                passengerName:    names,
                pnr:              booking.bookingReferenceNo,
                policyNo:         nil,
                cancellationDate: booking.cancelDate,
                refundDate:       booking.refundDate,
                cancelType:       nil,
                amount:           amountStr,
                agentNet:         agentNetStr,
                status:           normalizedStatus,
                carrierName:      nil,
                fareType:         nil,
                passengerCount:   passengers.count,
                passengers:       passengers
            )
        }
    }

    // MARK: CSV

    private func buildCSV() -> URL? {
        let rows = filteredRecords
        guard !rows.isEmpty else { return nil }

        let tab  = selectedTab.rawValue
        let from = cancelFromDate
        let to   = cancelToDate.isEmpty ? "" : cancelToDate

        let meta = [
            "Report:,My Refunds",
            "Category:,\(tab)",
            "From Date:,\(from)",
            "To Date:,\(to)",
            "",
        ]
        let header = "Booking Ref,PNR / Policy No,Passenger,Cancellation Date,Refund Amount,Status"
        let lines = rows.map { r in
            [r.bookingRef, r.secondaryRef, r.passengerName, r.cancellationDate, r.amount, r.status]
                .map { ($0 ?? "").replacingOccurrences(of: ",", with: ";") }
                .joined(separator: ",")
        }
        let csv = (meta + [header] + lines).joined(separator: "\n")
        let name = "Refunds_\(tab)_\(from.isEmpty ? "all" : from).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(name)
        try? csv.write(to: url, atomically: true, encoding: .utf8)
        return url
    }
}
