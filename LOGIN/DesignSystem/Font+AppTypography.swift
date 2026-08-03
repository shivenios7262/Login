import SwiftUI

extension Font {
    // MARK: - Fixed-size label fonts (use only where system styles don't fit)
    static let ftdBadgeXS    = Font.system(size: 7,  weight: .bold)
    static let ftdBadgeSM    = Font.system(size: 9,  weight: .bold)
    static let ftdLabelXS    = Font.system(size: 10, weight: .medium)
    static let ftdTabLabel   = Font.system(size: 10, weight: .regular)
    static let ftdTabLabelBold = Font.system(size: 10, weight: .semibold)
    static let ftdSectionHeader = Font.system(size: 11, weight: .semibold)
    static let ftdSectionHeaderMedium = Font.system(size: 18, weight: .medium)
    static let ftdIconEye    = Font.system(size: 16)
    static let ftdPrimaryIcon = Font.system(size: 34)
    static let ftdHeroIcon   = Font.system(size: 48)
    static let ftdSecondaryIcon = Font.system(size: 24)
    static let ftdPlaceholder   = Font.system(size: 12, weight: .regular)
}
