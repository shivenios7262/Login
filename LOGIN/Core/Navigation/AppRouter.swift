import SwiftUI

/// Single source of truth for all app navigation.
/// Injected at the root via `.environment(appRouter)` and read
/// with `@Environment(AppRouter.self)` wherever navigation is needed.
@Observable
@MainActor
final class AppRouter {

    // MARK: - Auth stack (push navigation)
    var authPath = NavigationPath()

    // MARK: - Home stack (push navigation)
    var homePath = NavigationPath()

    // MARK: - Auth sheet
    var authSheet: AuthSheet? = nil

    // MARK: - Home sheet
    var homeSheet: HomeSheet? = nil

    // MARK: - Home full-screen covers
    var uploadMoneyPresented: Bool = false
    var agencyStatementPresented: Bool = false
    var groupFarePresented: Bool = false
    var calendarPresented: Bool = false
    var refundPresented: Bool = false
    var markupsPresented: Bool = false
    var myBookingsPresented: Bool = false

    // MARK: - Destination types

    enum AuthDestination: Hashable {
        // reserved for future push destinations in the auth flow
    }

    enum HomeDestination: Hashable {
        case profile
        case profileEdit
    }

    enum AuthSheet: Identifiable {
        case forgotPassword
        case verifyOTP
        var id: Self { self }
    }

    enum HomeSheet: Identifiable {
        // .myBookings moved to fullScreenCover — use presentMyBookings() / myBookingsPresented
        // .statement removed — StatementView is an Excel export view, replaced by RefundView
        case markups
        case aboutUs
        case contactSupport
        case privacyPolicy
        case termsCondition
        case appCode
        var id: Self { self }
    }

    // MARK: - Navigation actions

//    func push(_ destination: AuthDestination) {
//        authPath.append(destination)
//    }

    func presentAuth(_ sheet: AuthSheet) {
        authSheet = sheet
    }

    func presentHome(_ sheet: HomeSheet) {
        homeSheet = sheet
    }

    func navigateHome(_ destination: HomeDestination) {
        homePath.append(destination)
    }

    func presentUploadMoney() {
        uploadMoneyPresented = true
    }

    func presentAgencyStatement() {
        agencyStatementPresented = true
    }

    func presentGroupFare() {
        groupFarePresented = true
    }

    func presentCalendar() {
        calendarPresented = true
    }

    func presentRefund() {
        refundPresented = true
    }

    func presentMarkups() {
        markupsPresented = true
    }

    func presentMyBookings() {
        myBookingsPresented = true
    }

    func popToAuthRoot() {
        authPath = NavigationPath()
    }
}
