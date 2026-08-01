import Foundation

enum APIEndpoint: Sendable {

    // MARK: - Agent Auth
    case appSignIn(AppSignInRequest)
    case agentLogin(AgentLoginRequest)
    case verifyOTP(VerifyOTPRequest)
    case resendOTP(ResendOTPRequest)
    case getOTP(ResendOTPRequest)
    case refreshToken(RefreshTokenRequest)

    // MARK: - Agent B2B
    case agentBookings(AgentBookingsRequest)
    case agentRefunds(AgentRefundsRequest)
    case agencyStatement(AgencyStatementRequest)
    case agentProfile
    case agentMarkups
    case agentCalendar
    case groupFaresRequest(GroupFaresRequest)
    case uploadMoney
    case uploadMoneyRequest(UploadMoneyRequest)
    case agentRegister(AgentRegisterRequest)

    // MARK: - Flights
    case flightDetails(UniqueRefNoRequest)
    case flightModifyEticket(ModifyEticketRequest)

    // MARK: - Bus
    case busDetails(UniqueRefNoRequest)
    case busModifyEticket(BusModifyEticketRequest)

    // MARK: - Cab
    case cabDetails(UniqueRefNoRequest)
    case cabModifyEticket(BusModifyEticketRequest)

    // MARK: - Hotel
    case hotelDetails(UniqueRefNoRequest)
    case hotelModifyEticket(ModifyEticketRequest)

    // MARK: - Insurance
    case insuranceDetails(UniqueRefNoRequest)
    case insuranceModifyEticket(ModifyEticketRequest)

    // MARK: - Visa
    case visaDetails(UniqueRefNoRequest)
    case visaModifyEticket(ModifyEticketRequest)

    // MARK: - eSIM
    case esimDetails(UniqueRefNoRequest)
    case esimModifyEticket(ModifyEticketRequest)

    // nonisolated: encoding is pure data transformation, not UI work.
    nonisolated func makeRequest() throws -> APIRequest {
        switch self {

        // MARK: Agent Auth
        case .appSignIn(let body):
            return APIRequest(
                path: "/book/mapp/auth/app_sigin",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: false,
                requiresBearerToken: false
            )
        case .agentLogin(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_login",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: false
            )
        case .verifyOTP(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/verify_otp",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: false
            )
        case .resendOTP(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/resend_otp",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: false
            )
        case .getOTP(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/get_otp",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: false
            )
        case .refreshToken(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/refresh_token",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: false
            )

        // MARK: Agent B2B
        case .agentBookings(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_bookings",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .agentRefunds(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_refunds",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .agencyStatement(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agency_statement",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .agentProfile:
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_profile",
                method: .get,
                body: nil,
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .agentMarkups:
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_markups",
                method: .get,
                body: nil,
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .agentCalendar:
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_calendar",
                method: .get,
                body: nil,
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .groupFaresRequest(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/group_fares_request",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .uploadMoney:
            return APIRequest(
                path: "/book/mapp/mapp_b2b/upload_money",
                method: .get,
                body: nil,
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .uploadMoneyRequest(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/upload_money_request",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .agentRegister(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_register",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: false
            )

        // MARK: Flights
        case .flightDetails(let body):
            return APIRequest(
                path: "/book/mapp/mapp_flights/flight_details",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .flightModifyEticket(let body):
            return APIRequest(
                path: "/book/mapp/mapp_flights/modify_eticket",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )

        // MARK: Bus
        case .busDetails(let body):
            return APIRequest(
                path: "/book/mapp/bus/bus_details",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .busModifyEticket(let body):
            return APIRequest(
                path: "/book/mapp/mapp_bus/modify_eticket",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )

        // MARK: Cab
        case .cabDetails(let body):
            return APIRequest(
                path: "/book/mapp/mapp_cab/cab_details",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .cabModifyEticket(let body):
            return APIRequest(
                path: "/book/mapp/mapp_cab/modify_eticket",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )

        // MARK: Hotel
        case .hotelDetails(let body):
            return APIRequest(
                path: "/book/mapp/mapp_hotel/hotel_details",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .hotelModifyEticket(let body):
            return APIRequest(
                path: "/book/mapp/mapp_hotel/modify_eticket",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )

        // MARK: Insurance
        case .insuranceDetails(let body):
            return APIRequest(
                path: "/book/mapp/mapp_insurance/insurance_details",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .insuranceModifyEticket(let body):
            return APIRequest(
                path: "/book/mapp/mapp_insurance/modify_eticket",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )

        // MARK: Visa
        case .visaDetails(let body):
            return APIRequest(
                path: "/book/mapp/mapp_visa/visa_details",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .visaModifyEticket(let body):
            return APIRequest(
                path: "/book/mapp/mapp_visa/modify_eticket",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )

        // MARK: eSIM
        case .esimDetails(let body):
            return APIRequest(
                path: "/book/mapp/mapp_esim/esim_details",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .esimModifyEticket(let body):
            return APIRequest(
                path: "/book/mapp/mapp_esim/modify_eticket",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        }
    }
}
