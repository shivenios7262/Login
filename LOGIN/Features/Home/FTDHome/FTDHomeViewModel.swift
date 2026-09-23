import Foundation
import Observation
import SwiftUI

@Observable
@MainActor
final class FTDHomeViewModel {
    private(set) var isSideMenuOpen = true
    var selectedTab: FTDHomeTab = .home
    var selectedOfferFilter: OfferFilter = .trending
    var showUpdateAlert = false
    private(set) var appStoreURL: URL? = nil
    private(set) var wallpaperImage: Image? = nil

    private let authManager: AuthManager

    // MARK: - Init

    init(authManager: AuthManager) {
        self.authManager = authManager
        Task { await prefetchWallpaper() }
    }

    // MARK: - Wallpaper

    func prefetchWallpaper() async {
        guard wallpaperImage == nil else { return }
        guard let (data, _) = try? await URLSession.shared.data(from: FTDImageURL.homeWallpaper),
              let uiImage = UIImage(data: data) else { return }
        wallpaperImage = Image(uiImage: uiImage)
    }

    // MARK: - Derived agent info

    var agentName: String {
        guard let user = authManager.currentUser else { return String(localized: "Travel Agent") }
        let name = user.displayName
        return name.isEmpty ? (user.agencyName ?? String(localized: "Travel Agent")) : name
    }

    var agentEmail: String      { authManager.currentUser?.agentEmail  ?? "" }
    var agencyName: String      { authManager.currentUser?.agencyName  ?? "" }
    var mobileNo: String        { authManager.currentUser?.mobileNo    ?? "" }
    var agentNo: String         { authManager.currentUser?.agentNo     ?? "" }

    var agentLogoURL: URL? {
        let raw = authManager.currentUser?.agentLogo
        let url = FTDImageURL.agentLogo(raw)
        print("[FTDHome] agentLogo raw: \(raw ?? "nil") → url: \(url?.absoluteString ?? "nil")")
        return url
    }

    var creditBalanceLabel: String {
        guard let b = authManager.currentUser?.creditBalance, !b.isEmpty else { return "₹ Balance" }
        return "₹\(b)"
    }

    var bookingBalanceLabel: String {
        guard let b = authManager.currentUser?.bookingBalance, !b.isEmpty else { return "" }
        return "₹\(b)"
    }

    var creditBalanceDisplayLabel: String {
        guard let b = authManager.currentUser?.creditBalance, !b.isEmpty else { return "" }
        return "₹\(b)"
    }

    var registerDate: String {
        guard let raw = authManager.currentUser?.registerDate else { return "" }
        return Self.formatAPIDate(raw)
    }

    var lastLogin: String {
        guard let raw = authManager.currentUser?.lastLogin else { return "" }
        return Self.formatAPIDate(raw)
    }

    var lastBooking: String {
        guard let raw = authManager.currentUser?.lastBooking else { return "" }
        return Self.formatAPIDate(raw)
    }

    // Parses "yyyy-MM-dd HH:mm:ss" or "yyyy-MM-dd" into a readable date string.
    private static func formatAPIDate(_ raw: String) -> String {
        let inputFormats = ["yyyy-MM-dd HH:mm:ss", "yyyy-MM-dd"]
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        for fmt in inputFormats {
            formatter.dateFormat = fmt
            if let date = formatter.date(from: raw) {
                formatter.dateStyle = .medium
                formatter.timeStyle = .none
                formatter.dateFormat = nil
                return formatter.string(from: date)
            }
        }
        return raw
    }

    // MARK: - Side menu

    func toggleSideMenu() { isSideMenuOpen.toggle() }
    func closeSideMenu()  { isSideMenuOpen = false }

    // MARK: - Session

    func checkAndRefreshTokenIfNeeded() async {
        await authManager.checkAndRefreshTokenIfNeeded()
    }

    func refreshBalance() async {
        await authManager.refreshBalance()
    }

    func logout() {
        closeSideMenu()
        authManager.logout()
    }

    // MARK: - App Store update check

    func checkForAppStoreUpdate() async {
        #if DEBUG
        return
        #endif
        guard let bundleId = Bundle.main.bundleIdentifier,
              let currentVersion = Bundle.main.infoDictionary?["APP_VERSION"] as? String,
              let url = URL(string: "https://itunes.apple.com/lookup?bundleId=\(bundleId)") else { return }
        guard let (data, _) = try? await URLSession.shared.data(from: url),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let result = (json["results"] as? [[String: Any]])?.first,
              let storeVersion = result["version"] as? String else { return }
        guard isVersion(storeVersion, newerThan: currentVersion) else { return }
        appStoreURL = (result["trackViewUrl"] as? String).flatMap(URL.init)
        showUpdateAlert = true
    }

    private func isVersion(_ a: String, newerThan b: String) -> Bool {
        let aParts = a.split(separator: ".").compactMap { Int($0) }
        let bParts = b.split(separator: ".").compactMap { Int($0) }
        for i in 0..<max(aParts.count, bParts.count) {
            let av = i < aParts.count ? aParts[i] : 0
            let bv = i < bParts.count ? bParts[i] : 0
            if av != bv { return av > bv }
        }
        return false
    }
}
