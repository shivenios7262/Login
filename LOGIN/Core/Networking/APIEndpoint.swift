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
    case updateAgentProfile(UpdateAgentProfileRequest)
    case changeAgentPassword(ChangeAgentPasswordRequest)
    case agentAddTraveller(AgentAddTravellerRequest)
    case agentEditTraveller(AgentEditTravellerRequest)
    case agentUpdateTraveller(AgentUpdateTravellerRequest)
    case agentDeleteTraveller(AgentDeleteTravellerRequest)
    case agentAddGST(AgentAddGSTRequest)
    case agentEditGST(AgentEditGSTRequest)
    case agentUpdateGST(AgentUpdateGSTRequest)
    case agentDeleteGST(AgentDeleteGSTRequest)
    case agentMarkups
    case agentSaveMarkups(AgentSaveMarkupsRequest)
    case agentCalendar
    case groupFaresRequest(GroupFaresRequest)
    case agentBalance
    case uploadMoney
    case uploadMoneyRequest(UploadMoneyRequest)
    case createPaymentOrder(CreatePaymentOrderRequest)
    case paymentCheckout(body: Data, isJSON: Bool)
    case agentRegister(AgentRegisterRequest)

    // MARK: - General
    case forgotPassword(ForgotPasswordRequest)
    case forgotPasswordLink(ForgotPasswordLinkRequest)
    case countries
    case termsCondition
    case privacy
    case contact(ContactRequest)

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
        case .updateAgentProfile(let body):
            if let logoData = body.logoData {
                let boundary = "Boundary-\(UUID().uuidString)"
                return APIRequest(
                    path: "/book/mapp/mapp_b2b/update_agent_profile",
                    method: .post,
                    body: APIEndpoint.buildMultipartBody(from: body, logoData: logoData, boundary: boundary),
                    contentType: "multipart/form-data; boundary=\(boundary)",
                    requiresAppToken: true,
                    requiresBearerToken: true
                )
            }
            return APIRequest(
                path: "/book/mapp/mapp_b2b/update_agent_profile",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .changeAgentPassword(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/change_agent_password",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .agentAddTraveller(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_add_travellers",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .agentEditTraveller(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_edit_travellers",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .agentUpdateTraveller(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_update_travellers",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .agentDeleteTraveller(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_delete_travellers",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .agentAddGST(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_add_gst",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .agentEditGST(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_edit_gst",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .agentUpdateGST(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_update_gst",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .agentDeleteGST(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_delete_gst",
                method: .post,
                body: try JSONEncoder().encode(body),
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
        case .agentSaveMarkups(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_save_markups",
                method: .post,
                body: try JSONEncoder().encode(body),
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
        case .agentBalance:
            return APIRequest(
                path: "/book/mapp/mapp_b2b/agent_balance",
                method: .get,
                body: nil,
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
        case .createPaymentOrder(let body):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/create_payment_order",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: true
            )
        case .paymentCheckout(let bodyData, let isJSON):
            return APIRequest(
                path: "/book/mapp/mapp_b2b/payment_checkout",
                method: .post,
                body: bodyData,
                contentType: isJSON ? "application/json" : "application/x-www-form-urlencoded",
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

        // MARK: General
        case .forgotPassword(let body):
            return APIRequest(
                path: "/book/mapp/mapp_general/forgot_password",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: false
            )
        case .forgotPasswordLink(let body):
            return APIRequest(
                path: "/book/mapp/mapp_general/forgot_password_link",
                method: .post,
                body: try JSONEncoder().encode(body),
                requiresAppToken: true,
                requiresBearerToken: false
            )
        case .countries:
            return APIRequest(
                path: "/book/mapp/mapp_general/countries",
                method: .get,
                body: nil,
                requiresAppToken: true,
                requiresBearerToken: false
            )
        case .termsCondition:
            return APIRequest(
                path: "/book/mapp/mapp_general/terms_condition",
                method: .get,
                body: nil,
                requiresAppToken: true,
                requiresBearerToken: false
            )
        case .privacy:
            return APIRequest(
                path: "/book/mapp/mapp_general/privacy",
                method: .get,
                body: nil,
                requiresAppToken: true,
                requiresBearerToken: false
            )
        case .contact(let body):
            return APIRequest(
                path: "/book/mapp/mapp_general/contact",
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
                path: "/book/mapp/mapp_bus/bus_details",
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

    // MARK: - Multipart Helper

    nonisolated private static func buildMultipartBody(
        from request: UpdateAgentProfileRequest,
        logoData: Data,
        boundary: String
    ) -> Data {
        var body = Data()
        let crlf = "\r\n"

        func append(_ string: String) {
            if let data = string.data(using: .utf8) { body.append(data) }
        }

        let textFields: [(String, String?)] = [
            ("title",           request.title),
            ("first_name",      request.firstName),
            ("middle_name",     request.middleName),
            ("last_name",       request.lastName),
            ("designation",     request.designation),
            ("website",         request.website),
            ("office_phone_no", request.officePhoneNo),
            ("fax",             request.fax),
            ("address",         request.address),
            ("city",            request.city),
            ("state",           request.state),
            ("country",         request.country),
            ("pin_code",        request.pinCode),
            ("gst_number",      request.gstNumber),
        ]

        for (name, value) in textFields {
            guard let value else { continue }
            append("--\(boundary)\(crlf)")
            append("Content-Disposition: form-data; name=\"\(name)\"\(crlf)\(crlf)")
            append("\(value)\(crlf)")
        }

        append("--\(boundary)\(crlf)")
        append("Content-Disposition: form-data; name=\"agency_logo\"; filename=\"logo.jpg\"\(crlf)")
        append("Content-Type: image/jpeg\(crlf)\(crlf)")
        body.append(logoData)
        append(crlf)
        append("--\(boundary)--\(crlf)")

        return body
    }
}
