import Foundation

// Bottom tab bar destinations.
enum FTDHomeTab: Int, CaseIterable, Identifiable {
    case home, myTrips, wishlists, creditCard

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home:       return "Home"
        case .myTrips:    return "Upload"
        case .wishlists:  return "Markup"
        case .creditCard: return "App Code"
        }
    }

    var icon: String {
        switch self {
        case .home:       return "house"
        case .myTrips:    return "wallet"
        case .wishlists:  return "markup"
        case .creditCard: return "appcode"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home:       return "house.fill"
        case .myTrips:    return "wallet"
        case .wishlists:  return "markup"
        case .creditCard: return "appcode"
        }
    }

    var isSystemIcon: Bool {
        switch self {
        case .home: return true
        default:    return false
        }
    }
}

// Filter chips on the Offers row.
enum OfferFilter: String, CaseIterable, Identifiable {
    case trending, flights, hotels, rails, holiday

    var id: String { rawValue }

    var title: String {
        switch self {
        case .trending: return "Trending"
        case .flights:  return "Flights"
        case .hotels:   return "Hotels"
        case .rails:    return "Rails"
        case .holiday:  return "Holiday"
        }
    }
}
