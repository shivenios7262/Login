import Foundation
import Observation

// MARK: - Supporting enums

enum MarkupTab: String, CaseIterable, Identifiable {
    case flight = "Flight"
    case bus    = "Bus"
    case cab    = "Cab"
    case hotel  = "Hotel"
    case esim   = "eSIM"
    var id: String { rawValue }
}

enum MarkupType: String, CaseIterable, Hashable {
    case fixed      = "Fixed"
    case percentage = "Percentage"

    // Bus / Cab / Hotel / eSIM use numeric process codes: Fixed=2, Percentage=1
    var markupProcess: String { self == .percentage ? "1" : "2" }
}

// MARK: - ViewModel

@Observable
@MainActor
final class MarkupsViewModel: MarkupsProvider {

    // MARK: Protocol requirements
    private(set) var markups: [MarkupItem] = []
    private(set) var isLoadingMarkups = false
    private(set) var markupsError: String? = nil

    // MARK: Tab
    var selectedTab: MarkupTab = .flight

    // MARK: Flight form
    var showNet: Bool = true
    var flightIntType: MarkupType  = .fixed
    var flightIntValue: String     = ""
    var flightDomType: MarkupType  = .fixed
    var flightDomValue: String     = ""

    // MARK: Bus form
    var busType: MarkupType  = .fixed
    var busValue: String     = ""

    // MARK: Cab form
    var cabType: MarkupType  = .fixed
    var cabValue: String     = ""

    // MARK: Hotel form
    var hotelDomType: MarkupType  = .fixed
    var hotelDomValue: String     = ""
    var hotelIntType: MarkupType  = .percentage
    var hotelIntValue: String     = ""

    // MARK: eSIM form
    var esimType: MarkupType  = .fixed
    var esimValue: String     = ""

    // MARK: Save state
    var isSaving: Bool       = false
    var saveSuccess: Bool    = false
    var saveError: String?   = nil

    private let authManager: AuthManager
    private var markupsData: AgentMarkupsData? = nil

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    // MARK: Fetch

    func fetchMarkups() async {
        do {
            isLoadingMarkups = true
            markupsError     = nil
            defer { isLoadingMarkups = false }
            let response = try await authManager.fetchMarkups()
            if response.status, let data = response.data {
                markupsData = data
                markups     = data.allItems
                populateFormFromData(data)
            } else {
                markupsError = response.message ?? String(localized: "Failed to load markups.")
            }
        } catch let e as NetworkError { markupsError = e.errorDescription
        } catch { markupsError = error.localizedDescription }
    }

    // MARK: Save

    func save() async {
        isSaving    = true
        saveSuccess = false
        saveError   = nil
        do {
            let request = buildSaveRequest()
            try await authManager.saveMarkups(request)
            isSaving    = false
            saveSuccess = true
        } catch let e as NetworkError {
            isSaving  = false
            saveError = e.errorDescription
        } catch {
            isSaving  = false
            saveError = error.localizedDescription
        }
    }

    private func buildSaveRequest() -> AgentSaveMarkupsRequest {
        switch selectedTab {
        case .flight:
            // Send all agentB2bMarkupManager entries.
            // INT entries use flightInt form values; all others (domestic airlines) use flightDom form values.
            let entries: [MarkupEntry] = (markupsData?.agentB2bMarkupManager ?? []).map { item in
                let isInt = item.airlineCode == "INT"
                return MarkupEntry(
                    domId:        item.domId,
                    airline:      item.airlines,
                    airlineCode:  item.airlineCode,
                    markupType:   isInt ? flightIntType.rawValue : flightDomType.rawValue,
                    markupValue1: isInt ? Double(flightIntValue) : Double(flightDomValue)
                )
            }
            return AgentSaveMarkupsRequest(module: "flight", displayNet: showNet ? 1 : 0, markups: entries)

        case .bus:
            let item = markupsData?.b2bBusMarkupList?.first
            return AgentSaveMarkupsRequest(
                module: "bus",
                domId: item?.domId,
                markupProcess: busType.markupProcess,
                markup: busValue
            )

        case .cab:
            let item = markupsData?.b2bCabMarkupList?.first
            return AgentSaveMarkupsRequest(
                module: "cab",
                domId: item?.domId,
                markupProcess: cabType.markupProcess,
                markup: cabValue
            )

        case .hotel:
            let item = markupsData?.b2bHotelMarkupList?.first
            return AgentSaveMarkupsRequest(
                module: "hotel",
                domId: item?.domId,
                markupProcess: hotelDomType.markupProcess,
                markup: hotelDomValue,
                intlMarkupProcess: hotelIntType.markupProcess,
                intlMarkup: hotelIntValue
            )

        case .esim:
            let item = markupsData?.b2bEsimMarkupList?.first
            return AgentSaveMarkupsRequest(
                module: "esim",
                domId: item?.domId,
                markupProcess: esimType.markupProcess,
                markup: esimValue
            )
        }
    }

    // MARK: Private helpers

    private func populateFormFromData(_ data: AgentMarkupsData) {
        showNet = data.displayNet == "1"

        // Flight generic markups keyed by airline_code
        if let entry = data.agentB2bMarkupManager?.first(where: { $0.airlineCode == "INT" }) {
            flightIntType  = MarkupType(rawValue: entry.markupType ?? "") ?? .fixed
            flightIntValue = entry.markupValue1 ?? ""
        }
        if let entry = data.agentB2bMarkupManager?.first(where: { $0.airlineCode == "DOM" }) {
            flightDomType  = MarkupType(rawValue: entry.markupType ?? "") ?? .fixed
            flightDomValue = entry.markupValue1 ?? ""
        }

        // Bus
        if let bus = data.b2bBusMarkupList?.first {
            busType  = bus.markupProcess == "1" ? .percentage : .fixed
            busValue = bus.markup ?? ""
        }

        // Cab
        if let cab = data.b2bCabMarkupList?.first {
            cabType  = cab.markupProcess == "1" ? .percentage : .fixed
            cabValue = cab.markup ?? ""
        }

        // Hotel (single row with separate dom/intl fields)
        if let hotel = data.b2bHotelMarkupList?.first {
            hotelDomType  = hotel.markupProcess == "1" ? .percentage : .fixed
            hotelDomValue = hotel.markup ?? ""
            hotelIntType  = hotel.intlMarkupProcess == "1" ? .percentage : .fixed
            hotelIntValue = hotel.intlMarkup ?? ""
        }

        // eSIM
        if let esim = data.b2bEsimMarkupList?.first {
            esimType  = esim.markupProcess == "1" ? .percentage : .fixed
            esimValue = esim.markup ?? ""
        }
    }
}
