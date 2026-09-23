import Foundation

/// Central registry for every remote image URL used in the app.
///
/// All image paths live here so that a CDN domain change, a path restructure,
/// or an http→https migration is a one-line fix.
enum FTDImageURL {

    // MARK: - Base strings (usable for local interpolation)

    /// Base for About-page marketing icons  (`https://www.ftd.travel/includes/img/`)
    static let aboutBase   = "https://www.ftd.travel/includes/img/"

    /// Base for Contact-Support banner images  (`https://ftd.travel/contact/img/`)
    static let contactBase = "https://ftd.travel/contact/img/"

    // MARK: - Static asset URLs

    static var homeWallpaper: URL {
        URL(string: "https://www.ftd.travel/book/public/images/signup-login-page/loginwallpaper.webp")!
    }

    static var groupFareBanner: URL {
        URL(string: "https://www.ftd.travel/book/public/img/groupfareBanner.webp")!
    }

    static var myBookingsBanner: URL {
        URL(string: "https://cdn.ftd.travel/book/public/img/gs/myBookingbg.webp")!
    }

    static var agentProfileBG: URL {
        URL(string: "https://cdn.ftd.travel/book/public/img/gs/agentprofileBG.webp")!
    }

    static var myRefundBanner: URL {
        URL(string: "http://13.200.42.214/book/public/img/gs/myBookingbg.webp")!
    }

    static var agentLogoDefault: URL {
        URL(string: "https://cdn.ftd.travel/book/public/img/gs/logoFixed.png")!
    }

    static var bankLogoFallback: URL {
        URL(string: "https://cdn.ftd.travel/book/public/img/logoSBI.svg")!
    }

    // MARK: - Dynamic builders

    /// Converts an agent-logo string from the API into a URL.
    /// The server at 13.200.42.214 is HTTP-only; Info.plist already has
    /// NSExceptionAllowsInsecureHTTPLoads for that host, so keep the raw scheme.
    static func agentLogo(_ raw: String?) -> URL? {
        guard let raw, !raw.isEmpty else { return nil }
        return URL(string: raw)
    }

    /// Upgrades http:// → https:// for CDN bank logo URLs returned by the API.
    static func bankLogo(_ raw: String?) -> URL? {
        guard let raw, !raw.isEmpty else { return nil }
        let secured = raw.hasPrefix("http://") ? "https://" + raw.dropFirst("http://".count) : raw
        return URL(string: secured)
    }

    /// URL for an About-page icon by filename (e.g. `"cs_flight.svg"`).
    static func aboutIcon(_ filename: String) -> URL? {
        URL(string: "\(aboutBase)\(filename)")
    }

    /// URL for a Contact-Support service banner by 1-based index (1…7).
    static func contactBanner(_ index: Int) -> URL? {
        URL(string: "\(contactBase)cuExpImg\(index).png")
    }
}
