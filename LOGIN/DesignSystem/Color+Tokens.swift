import SwiftUI
import UIKit

extension Color {
    // MARK: - Brand
    static let ftdAccentOrange       = Color("AccentOrange")
    static let ftdAccentTeal         = Color("AccentTeal")
    static let ftdAccentOrangeAlpha       = Color("AccentOrangeAlpha")
    

    // MARK: - Text
    static let ftdTextPrimary        = Color("TextPrimary")
    static let ftdTextSecondary      = Color("TextSecondary")
    static let ftdTextTertiary      = Color("text-tertiary")
    static let ftdTextShade      = Color("text-shade")
    
    static let ftdMessageBGInfo        = Color("message-bg-info")
    static let ftdMessageIconBGInfo    = Color("message-icon-bg-info")
    static let ftdMessageTextInfo      = Color("message-text-info")
    static let ftdMessageBGSuccess     = Color("message-bg-success")
    static let ftdMessageTextSuccess   = Color("message-text-success")

    // MARK: - Surfaces
    static let ftdCardBackground     = Color("CardBackground")
    static let ftdInputBackground    = Color("InputBackground")
    static let ftdSurfaceSubtle      = Color("surface-subtle")  // #F7F7F7 — light section backgrounds
    static let ftdDivider            = Color("divider")         // #DDDDDD — dividers and borders

    // MARK: - Certificate document
    static let ftdCertSealBlue       = Color(red: 0.14, green: 0.20, blue: 0.44)

    // MARK: - Financial indicators
    static let ftdDebitRed           = Color(red: 0.85, green: 0.15, blue: 0.15)
    static let ftdCreditGreen        = Color(red: 0.10, green: 0.60, blue: 0.25)
    static let ftdExcelGreen         = Color(red: 0.12, green: 0.56, blue: 0.27)

    // MARK: - Statement section header
    static let ftdStatementSectionBg = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.059, green: 0.149, blue: 0.227, alpha: 1) // #0F263A
            : UIColor(red: 0.937, green: 0.957, blue: 0.988, alpha: 1) // #EFF4FC
    })

    // MARK: - Chip states (adaptive light/dark)
    static let ftdChipSelectedBg = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.239, green: 0.133, blue: 0.0, alpha: 1)   // #3D2200
            : UIColor(red: 1.0,   green: 0.898, blue: 0.8,   alpha: 1) // #FFE5CC
    })
    static let ftdChipDeselectedBg   = Color("surface-subtle") // #F7F7F7 / #2C2C2E (dark)
    static let ftdChipDeselectedText = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.667, green: 0.667, blue: 0.667, alpha: 1) // #AAAAAA
            : UIColor(red: 0.333, green: 0.333, blue: 0.333, alpha: 1) // #555555
    })

    // MARK: - Borders & Feedback
    static let ftdBorder             = Color("BorderColor")
    static let ftdDestructiveRed     = Color("DestructiveRed")
    static let ftdRemarkRed          = Color("remark-red")        // #F6221E
    static let ftdBannerOrangeBG     = Color("banner-orange-bg")  // #FEF4EB
    static let ftdBannerOrangeTint   = Color("banner-orange-tint") // #FFE7D0
    static let ftdOrangeLabel        = Color("orange-label")      // #FF7F02

    // MARK: - Side Menu
    static let ftdSideMenuBackground = Color("SideMenuBackground")
    static let ftdSideMenuLogout     = Color("SideMenuLogoutButtonBg")
}

// MARK: - UIKit equivalents (for UIKit components that can't use SwiftUI Color)
extension UIColor {
    static let ftdAccentOrange  = UIColor(named: "AccentOrange") ?? .orange
    static let ftdTextOnAccent  = UIColor.white   // foreground on accent-colored backgrounds
    static let ftdCardBackground = UIColor(named: "CardBackground") ?? .systemBackground
}
