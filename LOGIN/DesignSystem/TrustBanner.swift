import SwiftUI

struct TrustBanner: View {
    var body: some View {
        InfoBanner(
            icon: .asset("iconShield"),
            showIconBackground: true,
            iconTint: .ftdAccentTeal,
            title: "Secure & Trusted",
            message: "Your data is safe with us, We never share your information"
        )
    }
}
