import Foundation

// Bottom tab bar destinations.
enum FTDHomeTab: Int, CaseIterable, Identifiable {
    case home, myTrips, wishlists, creditCard

    var id: Int { rawValue }

    var title: String {
        switch self {
        case .home:       return "Home"
        case .myTrips:    return "My Trips"
        case .wishlists:  return "Wishlists"
        case .creditCard: return "Credit Card"
        }
    }

    var icon: String {
        switch self {
        case .home:       return "house"
        case .myTrips:    return "bag"
        case .wishlists:  return "heart"
        case .creditCard: return "creditcard"
        }
    }

    var selectedIcon: String {
        switch self {
        case .home:       return "house.fill"
        case .myTrips:    return "bag.fill"
        case .wishlists:  return "heart.fill"
        case .creditCard: return "creditcard.fill"
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
