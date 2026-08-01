import SwiftUI

/// Single source of truth for all app navigation.
/// Injected at the root via `.environment(appRouter)` and read
/// with `@Environment(AppRouter.self)` wherever navigation is needed.
@Observable
@MainActor
final class AppRouter {

    // MARK: - Auth stack (push navigation)
    var authPath = NavigationPath()

    // MARK: - Auth sheet
    var authSheet: AuthSheet? = nil

    // MARK: - Home sheet
    var homeSheet: HomeSheet? = nil

    // MARK: - Destination types

    enum AuthDestination: Hashable {
        case verifyOTP
    }

    enum AuthSheet: Identifiable {
        case forgotPassword
        var id: Self { self }
    }

    enum HomeSheet: Identifiable {
        case myBookings
        case profile
        case statement
        case markups
        var id: Self { self }
    }

    // MARK: - Navigation actions

    func push(_ destination: AuthDestination) {
        authPath.append(destination)
    }

    func presentAuth(_ sheet: AuthSheet) {
        authSheet = sheet
    }

    func presentHome(_ sheet: HomeSheet) {
        homeSheet = sheet
    }

    func popToAuthRoot() {
        authPath = NavigationPath()
    }
}
