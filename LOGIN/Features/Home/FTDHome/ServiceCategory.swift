import Foundation

// Represents a single travel service tile on the home screen.
// Add, remove, or reorder entries in the static arrays to update the UI without touching any view code.
struct ServiceCategory: Identifiable {
    let id = UUID()
    let icon: String      // SF Symbol name
    let label: String
    let badge: String?    // e.g. "NEW", nil for no badge

    init(icon: String, label: String, badge: String? = nil) {
        self.icon = icon
        self.label = label
        self.badge = badge
    }
}

// MARK: - Static Data

extension ServiceCategory {
    /// Four prominent tiles displayed in a full-width row at the top of the grid.
    static let primaryCategories: [ServiceCategory] = [
        ServiceCategory(icon: "airplane",           label: "Flights"),
        ServiceCategory(icon: "building.2.fill",    label: "Hotels"),
        ServiceCategory(icon: "sun.horizon.fill",   label: "Holiday\nPackages"),
        ServiceCategory(icon: "tram.fill",          label: "Trains/Bus"),
    ]

    /// Twelve tiles displayed in a 4-column grid below the primary row.
    static let secondaryCategories: [ServiceCategory] = [
        ServiceCategory(icon: "car.fill",            label: "Airport\nCabs"),
        ServiceCategory(icon: "house.fill",          label: "Villas &\nHomestays"),
        ServiceCategory(icon: "car.2.fill",          label: "Outstation\nCabs"),
        ServiceCategory(icon: "creditcard.fill",     label: "Forex Card\n& Currency"),
        ServiceCategory(icon: "binoculars.fill",     label: "Tours &\nAttractions", badge: "NEW"),
        ServiceCategory(icon: "clock.fill",          label: "Hourly\nStays"),
        ServiceCategory(icon: "doc.badge.plus",      label: "Visa"),
        ServiceCategory(icon: "shield.fill",         label: "Travel\nInsurance"),
        ServiceCategory(icon: "map.fill",            label: "Nearby\nGetaways"),
        ServiceCategory(icon: "gift.fill",           label: "Gift Cards"),
        ServiceCategory(icon: "airplane.departure",  label: "Flight\nStatus"),
        ServiceCategory(icon: "qrcode.viewfinder",   label: "PNR Status"),
    ]
}
