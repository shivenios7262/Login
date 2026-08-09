import SwiftUI

extension Font {
    private static func poppins(_ weight: PoppinsWeight, size: CGFloat) -> Font {
        Font.custom(weight.rawValue, size: size)
    }

    private enum PoppinsWeight: String {
        case light    = "Poppins-Light"
        case regular  = "Poppins-Regular"
        case medium   = "Poppins-Medium"
        case semiBold = "Poppins-SemiBold"
        case bold     = "Poppins-Bold"
    }

    // MARK: - Fixed-size label fonts
    static let ftdBadgeXS             = poppins(.bold,     size: 7)
    static let ftdBadgeSM             = poppins(.bold,     size: 9)
    static let ftdLabelXS             = poppins(.medium,   size: 10)
    static let ftdTabLabel            = poppins(.regular,  size: 10)
    static let ftdTabLabelBold        = poppins(.semiBold, size: 10)
    static let ftdSectionHeader       = poppins(.semiBold, size: 11)
    static let ftdPlaceholder         = poppins(.regular,  size: 12)
    static let ftdBodySM              = poppins(.regular,  size: 14)   // list row text
    static let ftdLabelSM             = poppins(.semiBold, size: 14)   // button labels, CTAs
    static let ftdLabelMD             = poppins(.semiBold, size: 15)   // profile name, nav titles
    static let ftdSectionHeaderMedium = poppins(.medium,   size: 18)
    static let ftdAvatarLabel         = poppins(.bold,     size: 18)   // avatar initials
    static let ftdIconEye             = poppins(.regular,  size: 16)
    static let ftdPrimaryIcon         = poppins(.regular,  size: 34)
    static let ftdHeroIcon            = poppins(.regular,  size: 48)
    static let ftdSecondaryIcon       = poppins(.regular,  size: 24)
}
