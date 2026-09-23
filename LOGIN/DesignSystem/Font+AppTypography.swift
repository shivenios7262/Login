import SwiftUI
import UIKit

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
    static let ftdLabelXS             = poppins(.medium,   size: 12)
    static let ftdTabLabel            = poppins(.regular,  size: 10)
    static let ftdTabLabelBold        = poppins(.semiBold, size: 10)
    static let ftdSectionHeader       = poppins(.semiBold, size: 11)
    static let ftdPlaceholder         = poppins(.regular,  size: 12)
    static let ftdBodySM              = poppins(.regular,  size: 14)   // list row text
    static let ftdLabelSM             = poppins(.semiBold, size: 14)   // button labels, CTAs
    static let ftdLabelMD             = poppins(.medium, size: 14)   // profile name, nav titles
    static let ftdMenuName            = poppins(.semiBold, size: 18) // side menu agent name
    static let ftdSectionHeaderMedium = poppins(.medium,   size: 18)
    static let ftdAvatarLabel         = poppins(.bold,     size: 18)   // avatar initials
    static let ftdButton               = poppins(.medium,   size: 16)   // primary button / CTA label
    static let ftdBodyMD               = poppins(.regular,  size: 14)   // subtitle, body text
    static let ftdTitleLG              = poppins(.semiBold, size: 28)   // screen titles / auth welcome
  //  static let ftdWalletSymbol         = poppins(.semiBold, size: 24)   // wallet currency symbol (₹)
    static let ftdWalletAmount         = poppins(.semiBold,     size: 24)   // wallet balance numeric amount
    static let ftdOTPDigit             = poppins(.semiBold, size: 22)   // OTP box digit display
    static let ftdIconEye             = poppins(.regular,  size: 16)
    static let ftdPrimaryIcon         = poppins(.regular,  size: 34)
    static let ftdHeroIcon            = poppins(.regular,  size: 48)
    static let ftdSecondaryIcon       = poppins(.regular,  size: 24)

    // MARK: - Certificate document
    static let ftdCertLogoText      = poppins(.bold,     size: 32)   // logo letterforms ("f", "d")
    static let ftdCertLogoBadge     = poppins(.bold,     size: 8)    // logo wordmark "TRAVEL"
    static let ftdCertMetaValue     = poppins(.regular,  size: 11)   // CIN / GST values
    static let ftdCertCompanyName   = poppins(.bold,     size: 20)   // header company name
    static let ftdCertBody          = poppins(.regular,  size: 15)   // body copy
    static let ftdCertBodyBold      = poppins(.bold,     size: 15)   // inline bold within body copy
    static let ftdCertAgencyName    = poppins(.bold,     size: 28)   // certified agency name
    static let ftdCertDetailLabel   = poppins(.semiBold, size: 13)   // detail row labels
    static let ftdCertDetailValue   = poppins(.regular,  size: 13)   // detail row values
    static let ftdCertSealBadge     = poppins(.bold,     size: 5)    // seal wordmark
    static let ftdCertDirectorLabel = poppins(.semiBold, size: 16)   // director / signatory title
}

// MARK: - UIKit equivalents (for UIKit components that can't use SwiftUI Font)
extension UIFont {
    static let ftdLabelSM: UIFont  = UIFont(name: "Poppins-SemiBold", size: 14) ?? .systemFont(ofSize: 14, weight: .semibold)
    static let ftdLabelMD: UIFont  = UIFont(name: "Poppins-Medium",   size: 14) ?? .systemFont(ofSize: 14, weight: .medium)
    static let ftdBodyMD:  UIFont  = UIFont(name: "Poppins-Regular",  size: 14) ?? .systemFont(ofSize: 14)
}
