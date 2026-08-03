import Foundation

enum UserType: String, CaseIterable, Hashable {
    case travelAgent
    case customer
    case distributor
    case sales

    var displayName: String {
        switch self {
        case .travelAgent:  return String(localized: "Travel Agent")
        case .customer:     return String(localized: "Customer")
        case .distributor:  return String(localized: "Distributor")
        case .sales:        return String(localized: "Sales")
        }
    }

    var systemImage: String {
        switch self {
        case .travelAgent:  return "agent"
        case .customer:     return "customer"
        case .distributor:  return "distributor"
        case .sales:        return "sales"
        }
    }

    var apiValue: String { displayName }
}
