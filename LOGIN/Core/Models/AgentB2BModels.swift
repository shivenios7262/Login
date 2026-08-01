import Foundation

// MARK: - Agent Bookings

struct AgentBookingsRequest: Codable, Sendable {
    let searchType: Int
    // Flight filters
    let firstName: String?
    let pnr: String?
    let status: String?
    let bookingDate: String?
    let uniqueRefNo: String?
    let departDate: String?
    let fromDate: String?
    let toDate: String?
    let airline: String?
    // Bus filters
    let bBookingStatus: String?
    let bFromDate: String?
    let bToDate: String?
    let bBookingDate: String?
    let bUniqueRefNo: String?
    let bBookingReferenceNo1: String?
    let bPassName: String?
    let bDepartDate: String?
    // Cab filters
    let cPnr: String?
    let cUniqueRefNo: String?
    let cFromDate: String?
    let cToDate: String?
    let cDepartDate: String?
    let cStatus: String?
    let cFirstName: String?
    let cBookingDate: String?
    let carType: String?
    // Hotel filters
    let pnrHotel: String?
    let uniqueRefNoHotel: String?
    let checkInDate: String?
    let checkOutDate: String?
    let hotelStatus: String?
    // Insurance filters
    let referenceInsurance: String?
    let onwardDate: String?
    let returnDate: String?
    let countryName: String?
    let insuranceStatus: String?
    let insuranceType: String?
    // Visa filters
    let referenceVisa: String?
    let onwardDateVisa: String?
    let returnDateVisa: String?
    let countryNameVisa: String?
    // eSIM filters
    let referenceEsim: String?
    let esimFromDate: String?
    let esimToDate: String?

    enum CodingKeys: String, CodingKey {
        case searchType          = "search_type"
        case firstName           = "first_name"
        case pnr, status, airline
        case bookingDate         = "bookingdate"
        case uniqueRefNo         = "uniquerefno"
        case departDate          = "depart_date"
        case fromDate            = "from_date"
        case toDate              = "to_date"
        case bBookingStatus      = "b_Booking_Status"
        case bFromDate           = "b_from_date"
        case bToDate             = "b_to_date"
        case bBookingDate        = "b_booking_date"
        case bUniqueRefNo        = "b_uniqueRefNo"
        case bBookingReferenceNo1 = "b_booking_reference_no1"
        case bPassName           = "b_pass_name"
        case bDepartDate         = "b_depart_date"
        case cPnr                = "c_pnr"
        case cUniqueRefNo        = "c_uniquerefno"
        case cFromDate           = "c_from_date"
        case cToDate             = "c_to_date"
        case cDepartDate         = "c_depart_date"
        case cStatus             = "c_status"
        case cFirstName          = "c_first_name"
        case cBookingDate        = "c_bookingdate"
        case carType             = "car_type"
        case pnrHotel            = "pnr_hotel"
        case uniqueRefNoHotel    = "uniquerefno_hotel"
        case checkInDate         = "check_in_date"
        case checkOutDate        = "check_out_date"
        case hotelStatus         = "hotel_status"
        case referenceInsurance  = "reference_insurance"
        case onwardDate          = "onward_date"
        case returnDate          = "return_date"
        case countryName         = "country_name"
        case insuranceStatus     = "insurance_status"
        case insuranceType       = "insurance_type"
        case referenceVisa       = "reference_visa"
        case onwardDateVisa      = "onward_date_visa"
        case returnDateVisa      = "return_date_visa"
        case countryNameVisa     = "country_name_visa"
        case referenceEsim       = "reference_esim"
        case esimFromDate        = "esim_from_date"
        case esimToDate          = "esim_to_date"
    }

    nonisolated init(
        searchType: Int,
        firstName: String? = nil, pnr: String? = nil, status: String? = nil,
        bookingDate: String? = nil, uniqueRefNo: String? = nil, departDate: String? = nil,
        fromDate: String? = nil, toDate: String? = nil, airline: String? = nil,
        bBookingStatus: String? = nil, bFromDate: String? = nil, bToDate: String? = nil,
        bBookingDate: String? = nil, bUniqueRefNo: String? = nil,
        bBookingReferenceNo1: String? = nil, bPassName: String? = nil, bDepartDate: String? = nil,
        cPnr: String? = nil, cUniqueRefNo: String? = nil, cFromDate: String? = nil,
        cToDate: String? = nil, cDepartDate: String? = nil, cStatus: String? = nil,
        cFirstName: String? = nil, cBookingDate: String? = nil, carType: String? = nil,
        pnrHotel: String? = nil, uniqueRefNoHotel: String? = nil,
        checkInDate: String? = nil, checkOutDate: String? = nil, hotelStatus: String? = nil,
        referenceInsurance: String? = nil, onwardDate: String? = nil, returnDate: String? = nil,
        countryName: String? = nil, insuranceStatus: String? = nil, insuranceType: String? = nil,
        referenceVisa: String? = nil, onwardDateVisa: String? = nil, returnDateVisa: String? = nil,
        countryNameVisa: String? = nil,
        referenceEsim: String? = nil, esimFromDate: String? = nil, esimToDate: String? = nil
    ) {
        self.searchType          = searchType
        self.firstName           = firstName
        self.pnr                 = pnr
        self.status              = status
        self.bookingDate         = bookingDate
        self.uniqueRefNo         = uniqueRefNo
        self.departDate          = departDate
        self.fromDate            = fromDate
        self.toDate              = toDate
        self.airline             = airline
        self.bBookingStatus      = bBookingStatus
        self.bFromDate           = bFromDate
        self.bToDate             = bToDate
        self.bBookingDate        = bBookingDate
        self.bUniqueRefNo        = bUniqueRefNo
        self.bBookingReferenceNo1 = bBookingReferenceNo1
        self.bPassName           = bPassName
        self.bDepartDate         = bDepartDate
        self.cPnr                = cPnr
        self.cUniqueRefNo        = cUniqueRefNo
        self.cFromDate           = cFromDate
        self.cToDate             = cToDate
        self.cDepartDate         = cDepartDate
        self.cStatus             = cStatus
        self.cFirstName          = cFirstName
        self.cBookingDate        = cBookingDate
        self.carType             = carType
        self.pnrHotel            = pnrHotel
        self.uniqueRefNoHotel    = uniqueRefNoHotel
        self.checkInDate         = checkInDate
        self.checkOutDate        = checkOutDate
        self.hotelStatus         = hotelStatus
        self.referenceInsurance  = referenceInsurance
        self.onwardDate          = onwardDate
        self.returnDate          = returnDate
        self.countryName         = countryName
        self.insuranceStatus     = insuranceStatus
        self.insuranceType       = insuranceType
        self.referenceVisa       = referenceVisa
        self.onwardDateVisa      = onwardDateVisa
        self.returnDateVisa      = returnDateVisa
        self.countryNameVisa     = countryNameVisa
        self.referenceEsim       = referenceEsim
        self.esimFromDate        = esimFromDate
        self.esimToDate          = esimToDate
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        searchType           = try c.decode(Int.self,    forKey: .searchType)
        firstName            = try c.decodeIfPresent(String.self, forKey: .firstName)
        pnr                  = try c.decodeIfPresent(String.self, forKey: .pnr)
        status               = try c.decodeIfPresent(String.self, forKey: .status)
        bookingDate          = try c.decodeIfPresent(String.self, forKey: .bookingDate)
        uniqueRefNo          = try c.decodeIfPresent(String.self, forKey: .uniqueRefNo)
        departDate           = try c.decodeIfPresent(String.self, forKey: .departDate)
        fromDate             = try c.decodeIfPresent(String.self, forKey: .fromDate)
        toDate               = try c.decodeIfPresent(String.self, forKey: .toDate)
        airline              = try c.decodeIfPresent(String.self, forKey: .airline)
        bBookingStatus       = try c.decodeIfPresent(String.self, forKey: .bBookingStatus)
        bFromDate            = try c.decodeIfPresent(String.self, forKey: .bFromDate)
        bToDate              = try c.decodeIfPresent(String.self, forKey: .bToDate)
        bBookingDate         = try c.decodeIfPresent(String.self, forKey: .bBookingDate)
        bUniqueRefNo         = try c.decodeIfPresent(String.self, forKey: .bUniqueRefNo)
        bBookingReferenceNo1 = try c.decodeIfPresent(String.self, forKey: .bBookingReferenceNo1)
        bPassName            = try c.decodeIfPresent(String.self, forKey: .bPassName)
        bDepartDate          = try c.decodeIfPresent(String.self, forKey: .bDepartDate)
        cPnr                 = try c.decodeIfPresent(String.self, forKey: .cPnr)
        cUniqueRefNo         = try c.decodeIfPresent(String.self, forKey: .cUniqueRefNo)
        cFromDate            = try c.decodeIfPresent(String.self, forKey: .cFromDate)
        cToDate              = try c.decodeIfPresent(String.self, forKey: .cToDate)
        cDepartDate          = try c.decodeIfPresent(String.self, forKey: .cDepartDate)
        cStatus              = try c.decodeIfPresent(String.self, forKey: .cStatus)
        cFirstName           = try c.decodeIfPresent(String.self, forKey: .cFirstName)
        cBookingDate         = try c.decodeIfPresent(String.self, forKey: .cBookingDate)
        carType              = try c.decodeIfPresent(String.self, forKey: .carType)
        pnrHotel             = try c.decodeIfPresent(String.self, forKey: .pnrHotel)
        uniqueRefNoHotel     = try c.decodeIfPresent(String.self, forKey: .uniqueRefNoHotel)
        checkInDate          = try c.decodeIfPresent(String.self, forKey: .checkInDate)
        checkOutDate         = try c.decodeIfPresent(String.self, forKey: .checkOutDate)
        hotelStatus          = try c.decodeIfPresent(String.self, forKey: .hotelStatus)
        referenceInsurance   = try c.decodeIfPresent(String.self, forKey: .referenceInsurance)
        onwardDate           = try c.decodeIfPresent(String.self, forKey: .onwardDate)
        returnDate           = try c.decodeIfPresent(String.self, forKey: .returnDate)
        countryName          = try c.decodeIfPresent(String.self, forKey: .countryName)
        insuranceStatus      = try c.decodeIfPresent(String.self, forKey: .insuranceStatus)
        insuranceType        = try c.decodeIfPresent(String.self, forKey: .insuranceType)
        referenceVisa        = try c.decodeIfPresent(String.self, forKey: .referenceVisa)
        onwardDateVisa       = try c.decodeIfPresent(String.self, forKey: .onwardDateVisa)
        returnDateVisa       = try c.decodeIfPresent(String.self, forKey: .returnDateVisa)
        countryNameVisa      = try c.decodeIfPresent(String.self, forKey: .countryNameVisa)
        referenceEsim        = try c.decodeIfPresent(String.self, forKey: .referenceEsim)
        esimFromDate         = try c.decodeIfPresent(String.self, forKey: .esimFromDate)
        esimToDate           = try c.decodeIfPresent(String.self, forKey: .esimToDate)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(searchType, forKey: .searchType)
        try c.encodeIfPresent(firstName,            forKey: .firstName)
        try c.encodeIfPresent(pnr,                  forKey: .pnr)
        try c.encodeIfPresent(status,               forKey: .status)
        try c.encodeIfPresent(bookingDate,           forKey: .bookingDate)
        try c.encodeIfPresent(uniqueRefNo,           forKey: .uniqueRefNo)
        try c.encodeIfPresent(departDate,            forKey: .departDate)
        try c.encodeIfPresent(fromDate,              forKey: .fromDate)
        try c.encodeIfPresent(toDate,                forKey: .toDate)
        try c.encodeIfPresent(airline,               forKey: .airline)
        try c.encodeIfPresent(bBookingStatus,        forKey: .bBookingStatus)
        try c.encodeIfPresent(bFromDate,             forKey: .bFromDate)
        try c.encodeIfPresent(bToDate,               forKey: .bToDate)
        try c.encodeIfPresent(bBookingDate,          forKey: .bBookingDate)
        try c.encodeIfPresent(bUniqueRefNo,          forKey: .bUniqueRefNo)
        try c.encodeIfPresent(bBookingReferenceNo1,  forKey: .bBookingReferenceNo1)
        try c.encodeIfPresent(bPassName,             forKey: .bPassName)
        try c.encodeIfPresent(bDepartDate,           forKey: .bDepartDate)
        try c.encodeIfPresent(cPnr,                  forKey: .cPnr)
        try c.encodeIfPresent(cUniqueRefNo,          forKey: .cUniqueRefNo)
        try c.encodeIfPresent(cFromDate,             forKey: .cFromDate)
        try c.encodeIfPresent(cToDate,               forKey: .cToDate)
        try c.encodeIfPresent(cDepartDate,           forKey: .cDepartDate)
        try c.encodeIfPresent(cStatus,               forKey: .cStatus)
        try c.encodeIfPresent(cFirstName,            forKey: .cFirstName)
        try c.encodeIfPresent(cBookingDate,          forKey: .cBookingDate)
        try c.encodeIfPresent(carType,               forKey: .carType)
        try c.encodeIfPresent(pnrHotel,              forKey: .pnrHotel)
        try c.encodeIfPresent(uniqueRefNoHotel,      forKey: .uniqueRefNoHotel)
        try c.encodeIfPresent(checkInDate,           forKey: .checkInDate)
        try c.encodeIfPresent(checkOutDate,          forKey: .checkOutDate)
        try c.encodeIfPresent(hotelStatus,           forKey: .hotelStatus)
        try c.encodeIfPresent(referenceInsurance,    forKey: .referenceInsurance)
        try c.encodeIfPresent(onwardDate,            forKey: .onwardDate)
        try c.encodeIfPresent(returnDate,            forKey: .returnDate)
        try c.encodeIfPresent(countryName,           forKey: .countryName)
        try c.encodeIfPresent(insuranceStatus,       forKey: .insuranceStatus)
        try c.encodeIfPresent(insuranceType,         forKey: .insuranceType)
        try c.encodeIfPresent(referenceVisa,         forKey: .referenceVisa)
        try c.encodeIfPresent(onwardDateVisa,        forKey: .onwardDateVisa)
        try c.encodeIfPresent(returnDateVisa,        forKey: .returnDateVisa)
        try c.encodeIfPresent(countryNameVisa,       forKey: .countryNameVisa)
        try c.encodeIfPresent(referenceEsim,         forKey: .referenceEsim)
        try c.encodeIfPresent(esimFromDate,          forKey: .esimFromDate)
        try c.encodeIfPresent(esimToDate,            forKey: .esimToDate)
    }
}

// MARK: - Agent Bookings Response
// Actual response shape confirmed from live API:
// data: { "flight_booking_summary": [ { "uniquerefno", "status", "origin", "destination",
//   "pnr", "carrier", "carriername", "departuredate", "departuretime", "totalfare",
//   "agent_net_price", "origin_city", "destination_city", "passengers": [...], ... } ] }

struct FlightPassenger: Codable, Sendable {
    let title: String?
    let firstName: String?
    let lastName: String?
    let passengerType: String?

    enum CodingKeys: String, CodingKey {
        case title
        case firstName     = "first_name"
        case lastName      = "last_name"
        case passengerType = "passenger_type"
    }

    nonisolated init(title: String?, firstName: String?, lastName: String?, passengerType: String?) {
        self.title = title; self.firstName = firstName
        self.lastName = lastName; self.passengerType = passengerType
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        title         = try c.decodeIfPresent(String.self, forKey: .title)
        firstName     = try c.decodeIfPresent(String.self, forKey: .firstName)
        lastName      = try c.decodeIfPresent(String.self, forKey: .lastName)
        passengerType = try c.decodeIfPresent(String.self, forKey: .passengerType)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(title,         forKey: .title)
        try c.encodeIfPresent(firstName,     forKey: .firstName)
        try c.encodeIfPresent(lastName,      forKey: .lastName)
        try c.encodeIfPresent(passengerType, forKey: .passengerType)
    }

    var fullName: String {
        [title, firstName, lastName]
            .compactMap { $0?.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
            .joined(separator: " ")
    }
}

struct AgentFlightBooking: Codable, Sendable, Identifiable {
    var id: String { uniqueRefNo ?? pnr ?? UUID().uuidString }
    let uniqueRefNo: String?
    let tripType: String?
    let bookingDate: String?
    let status: String?
    let origin: String?
    let destination: String?
    let pnr: String?
    let carrier: String?
    let carrierName: String?
    let fareTypeDesc: String?
    let departureDate: String?
    let departureTime: String?
    let totalFare: String?
    let agentNetPrice: String?
    let originCity: String?
    let destinationCity: String?
    let passengers: [FlightPassenger]?

    enum CodingKeys: String, CodingKey {
        case uniqueRefNo     = "uniquerefno"
        case tripType        = "triptype"
        case bookingDate     = "bookingdate"
        case status, origin, destination, pnr, carrier
        case carrierName     = "carriername"
        case fareTypeDesc    = "faretypedesc"
        case departureDate   = "departuredate"
        case departureTime   = "departuretime"
        case totalFare       = "totalfare"
        case agentNetPrice   = "agent_net_price"
        case originCity      = "origin_city"
        case destinationCity = "destination_city"
        case passengers
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        uniqueRefNo     = try c.decodeIfPresent(String.self, forKey: .uniqueRefNo)
        tripType        = try c.decodeIfPresent(String.self, forKey: .tripType)
        bookingDate     = try c.decodeIfPresent(String.self, forKey: .bookingDate)
        status          = try c.decodeIfPresent(String.self, forKey: .status)
        origin          = try c.decodeIfPresent(String.self, forKey: .origin)
        destination     = try c.decodeIfPresent(String.self, forKey: .destination)
        pnr             = try c.decodeIfPresent(String.self, forKey: .pnr)
        carrier         = try c.decodeIfPresent(String.self, forKey: .carrier)
        carrierName     = try c.decodeIfPresent(String.self, forKey: .carrierName)
        fareTypeDesc    = try c.decodeIfPresent(String.self, forKey: .fareTypeDesc)
        departureDate   = try c.decodeIfPresent(String.self, forKey: .departureDate)
        departureTime   = try c.decodeIfPresent(String.self, forKey: .departureTime)
        totalFare       = try c.decodeIfPresent(String.self, forKey: .totalFare)
        agentNetPrice   = try c.decodeIfPresent(String.self, forKey: .agentNetPrice)
        originCity      = try c.decodeIfPresent(String.self, forKey: .originCity)
        destinationCity = try c.decodeIfPresent(String.self, forKey: .destinationCity)
        passengers      = try c.decodeIfPresent([FlightPassenger].self, forKey: .passengers)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(uniqueRefNo,     forKey: .uniqueRefNo)
        try c.encodeIfPresent(tripType,        forKey: .tripType)
        try c.encodeIfPresent(bookingDate,     forKey: .bookingDate)
        try c.encodeIfPresent(status,          forKey: .status)
        try c.encodeIfPresent(origin,          forKey: .origin)
        try c.encodeIfPresent(destination,     forKey: .destination)
        try c.encodeIfPresent(pnr,             forKey: .pnr)
        try c.encodeIfPresent(carrier,         forKey: .carrier)
        try c.encodeIfPresent(carrierName,     forKey: .carrierName)
        try c.encodeIfPresent(fareTypeDesc,    forKey: .fareTypeDesc)
        try c.encodeIfPresent(departureDate,   forKey: .departureDate)
        try c.encodeIfPresent(departureTime,   forKey: .departureTime)
        try c.encodeIfPresent(totalFare,       forKey: .totalFare)
        try c.encodeIfPresent(agentNetPrice,   forKey: .agentNetPrice)
        try c.encodeIfPresent(originCity,      forKey: .originCity)
        try c.encodeIfPresent(destinationCity, forKey: .destinationCity)
        try c.encodeIfPresent(passengers,      forKey: .passengers)
    }
}

struct AgentBookingsData: Codable, Sendable {
    let flightBookingSummary: [AgentFlightBooking]?

    enum CodingKeys: String, CodingKey {
        case flightBookingSummary = "flight_booking_summary"
    }

    nonisolated init(flightBookingSummary: [AgentFlightBooking]?) {
        self.flightBookingSummary = flightBookingSummary
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        flightBookingSummary = try c.decodeIfPresent([AgentFlightBooking].self, forKey: .flightBookingSummary)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(flightBookingSummary, forKey: .flightBookingSummary)
    }
}

struct AgentBookingsResponse: Codable, Sendable {
    let status: Bool
    let message: String?
    let data: AgentBookingsData?

    enum CodingKeys: String, CodingKey { case status, message, data }

    nonisolated init(status: Bool, message: String?, data: AgentBookingsData?) {
        self.status = status; self.message = message; self.data = data
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        status  = try c.decode(Bool.self, forKey: .status)
        message = try c.decodeIfPresent(String.self,          forKey: .message)
        data    = try c.decodeIfPresent(AgentBookingsData.self, forKey: .data)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(message, forKey: .message)
        try c.encodeIfPresent(data,    forKey: .data)
    }
}

// MARK: - Agent Profile Response

struct AgentProfileData: Codable, Sendable {
    let agentId: String?
    let distId: String?
    let agentNo: String?
    let agencyName: String?
    let agentEmail: String?
    let agentLogo: String?
    let title: String?
    let firstName: String?
    let lastName: String?
    let mobileNo: String?
    let officePhoneNo: String?
    let creditBalance: String?
    let bookingBalance: String?
    let address: String?
    let city: String?
    let state: String?
    let country: String?
    let pinCode: String?
    let panNo: String?
    let website: String?
    let agentType: String?

    enum CodingKeys: String, CodingKey {
        case title, address, city, state, country, website
        case agentId       = "agent_id"
        case distId        = "dist_id"
        case agentNo       = "agent_no"
        case agencyName    = "agency_name"
        case agentEmail    = "agent_email"
        case agentLogo     = "agent_logo"
        case firstName     = "first_name"
        case lastName      = "last_name"
        case mobileNo      = "mobile_no"
        case officePhoneNo = "office_phone_no"
        case creditBalance = "creditbalance"
        case bookingBalance = "bookingbalance"
        case pinCode       = "pin_code"
        case panNo         = "pan_no"
        case agentType     = "agent_type"
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        agentId       = try c.decodeIfPresent(String.self, forKey: .agentId)
        distId        = try c.decodeIfPresent(String.self, forKey: .distId)
        agentNo       = try c.decodeIfPresent(String.self, forKey: .agentNo)
        agencyName    = try c.decodeIfPresent(String.self, forKey: .agencyName)
        agentEmail    = try c.decodeIfPresent(String.self, forKey: .agentEmail)
        agentLogo     = try c.decodeIfPresent(String.self, forKey: .agentLogo)
        title         = try c.decodeIfPresent(String.self, forKey: .title)
        firstName     = try c.decodeIfPresent(String.self, forKey: .firstName)
        lastName      = try c.decodeIfPresent(String.self, forKey: .lastName)
        mobileNo      = try c.decodeIfPresent(String.self, forKey: .mobileNo)
        officePhoneNo = try c.decodeIfPresent(String.self, forKey: .officePhoneNo)
        creditBalance = try c.decodeIfPresent(String.self, forKey: .creditBalance)
        bookingBalance = try c.decodeIfPresent(String.self, forKey: .bookingBalance)
        address       = try c.decodeIfPresent(String.self, forKey: .address)
        city          = try c.decodeIfPresent(String.self, forKey: .city)
        state         = try c.decodeIfPresent(String.self, forKey: .state)
        country       = try c.decodeIfPresent(String.self, forKey: .country)
        pinCode       = try c.decodeIfPresent(String.self, forKey: .pinCode)
        panNo         = try c.decodeIfPresent(String.self, forKey: .panNo)
        website       = try c.decodeIfPresent(String.self, forKey: .website)
        agentType     = try c.decodeIfPresent(String.self, forKey: .agentType)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(agentId,        forKey: .agentId)
        try c.encodeIfPresent(distId,         forKey: .distId)
        try c.encodeIfPresent(agentNo,        forKey: .agentNo)
        try c.encodeIfPresent(agencyName,     forKey: .agencyName)
        try c.encodeIfPresent(agentEmail,     forKey: .agentEmail)
        try c.encodeIfPresent(agentLogo,      forKey: .agentLogo)
        try c.encodeIfPresent(title,          forKey: .title)
        try c.encodeIfPresent(firstName,      forKey: .firstName)
        try c.encodeIfPresent(lastName,       forKey: .lastName)
        try c.encodeIfPresent(mobileNo,       forKey: .mobileNo)
        try c.encodeIfPresent(officePhoneNo,  forKey: .officePhoneNo)
        try c.encodeIfPresent(creditBalance,  forKey: .creditBalance)
        try c.encodeIfPresent(bookingBalance, forKey: .bookingBalance)
        try c.encodeIfPresent(address,        forKey: .address)
        try c.encodeIfPresent(city,           forKey: .city)
        try c.encodeIfPresent(state,          forKey: .state)
        try c.encodeIfPresent(country,        forKey: .country)
        try c.encodeIfPresent(pinCode,        forKey: .pinCode)
        try c.encodeIfPresent(panNo,          forKey: .panNo)
        try c.encodeIfPresent(website,        forKey: .website)
        try c.encodeIfPresent(agentType,      forKey: .agentType)
    }
}

struct AgentProfileResponse: Codable, Sendable {
    let status: Bool
    let message: String?
    let data: AgentProfileData?

    enum CodingKeys: String, CodingKey { case status, message, data }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        status  = try c.decode(Bool.self, forKey: .status)
        message = try c.decodeIfPresent(String.self,          forKey: .message)
        data    = try c.decodeIfPresent(AgentProfileData.self, forKey: .data)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(message, forKey: .message)
        try c.encodeIfPresent(data,    forKey: .data)
    }
}

// MARK: - Agency Statement Response

struct StatementItem: Codable, Sendable, Identifiable {
    var id: String { referenceNo ?? bookingId ?? UUID().uuidString }
    let date: String?
    let description: String?
    let debit: String?
    let credit: String?
    let balance: String?
    let referenceNo: String?
    let bookingId: String?
    let transactionType: String?
    let serviceType: String?

    enum CodingKeys: String, CodingKey {
        case date, description, debit, credit, balance
        case referenceNo     = "reference_no"
        case bookingId       = "booking_id"
        case transactionType = "transaction_type"
        case serviceType     = "service_type"
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        date            = try c.decodeIfPresent(String.self, forKey: .date)
        description     = try c.decodeIfPresent(String.self, forKey: .description)
        debit           = try c.decodeIfPresent(String.self, forKey: .debit)
        credit          = try c.decodeIfPresent(String.self, forKey: .credit)
        balance         = try c.decodeIfPresent(String.self, forKey: .balance)
        referenceNo     = try c.decodeIfPresent(String.self, forKey: .referenceNo)
        bookingId       = try c.decodeIfPresent(String.self, forKey: .bookingId)
        transactionType = try c.decodeIfPresent(String.self, forKey: .transactionType)
        serviceType     = try c.decodeIfPresent(String.self, forKey: .serviceType)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(date,            forKey: .date)
        try c.encodeIfPresent(description,     forKey: .description)
        try c.encodeIfPresent(debit,           forKey: .debit)
        try c.encodeIfPresent(credit,          forKey: .credit)
        try c.encodeIfPresent(balance,         forKey: .balance)
        try c.encodeIfPresent(referenceNo,     forKey: .referenceNo)
        try c.encodeIfPresent(bookingId,       forKey: .bookingId)
        try c.encodeIfPresent(transactionType, forKey: .transactionType)
        try c.encodeIfPresent(serviceType,     forKey: .serviceType)
    }
}

struct AgencyStatementResponse: Codable, Sendable {
    let status: Bool
    let message: String?
    let data: [StatementItem]?

    enum CodingKeys: String, CodingKey { case status, message, data }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        status  = try c.decode(Bool.self, forKey: .status)
        message = try c.decodeIfPresent(String.self,        forKey: .message)
        data    = try c.decodeIfPresent([StatementItem].self, forKey: .data)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(message, forKey: .message)
        try c.encodeIfPresent(data,    forKey: .data)
    }
}

// MARK: - Agent Markups Response

struct MarkupItem: Codable, Sendable, Identifiable {
    var id: String { serviceType ?? UUID().uuidString }
    let serviceType: String?
    let markupType: String?
    let markupValue: String?
    let airline: String?
    let cabType: String?

    enum CodingKeys: String, CodingKey {
        case airline
        case serviceType  = "service_type"
        case markupType   = "markup_type"
        case markupValue  = "markup_value"
        case cabType      = "cab_type"
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        serviceType  = try c.decodeIfPresent(String.self, forKey: .serviceType)
        markupType   = try c.decodeIfPresent(String.self, forKey: .markupType)
        markupValue  = try c.decodeIfPresent(String.self, forKey: .markupValue)
        airline      = try c.decodeIfPresent(String.self, forKey: .airline)
        cabType      = try c.decodeIfPresent(String.self, forKey: .cabType)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(serviceType,  forKey: .serviceType)
        try c.encodeIfPresent(markupType,   forKey: .markupType)
        try c.encodeIfPresent(markupValue,  forKey: .markupValue)
        try c.encodeIfPresent(airline,      forKey: .airline)
        try c.encodeIfPresent(cabType,      forKey: .cabType)
    }
}

struct AgentMarkupsResponse: Codable, Sendable {
    let status: Bool
    let message: String?
    let data: [MarkupItem]?

    enum CodingKeys: String, CodingKey { case status, message, data }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        status  = try c.decode(Bool.self, forKey: .status)
        message = try c.decodeIfPresent(String.self,     forKey: .message)
        data    = try c.decodeIfPresent([MarkupItem].self, forKey: .data)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(message, forKey: .message)
        try c.encodeIfPresent(data,    forKey: .data)
    }
}

// MARK: - Agent Refunds

struct AgentRefundsRequest: Codable, Sendable {
    let searchType: Int
    // Flight
    let fromDate: String?
    let toDate: String?
    let bookingId: String?
    // Hotel
    let hFromDate: String?
    let hToDate: String?
    let hBookingId: String?
    // Bus
    let bFromDate: String?
    let bToDate: String?
    let bBookingId: String?
    // Cab
    let cFromDate: String?
    let cToDate: String?
    let cBookingId: String?
    // Insurance
    let iFromDate: String?
    let iToDate: String?
    let iBookingId: String?
    // Visa
    let vFromDate: String?
    let vToDate: String?
    let vBookingId: String?
    // eSIM
    let eFromDate: String?
    let eToDate: String?
    let eBookingId: String?

    enum CodingKeys: String, CodingKey {
        case searchType = "search_type"
        case fromDate   = "fromdate"
        case toDate     = "todate"
        case bookingId  = "bookingid"
        case hFromDate  = "h_fromdate"
        case hToDate    = "h_todate"
        case hBookingId = "h_bookingid"
        case bFromDate  = "b_fromdate"
        case bToDate    = "b_todate"
        case bBookingId = "b_bookingid"
        case cFromDate  = "c_fromdate"
        case cToDate    = "c_todate"
        case cBookingId = "c_bookingid"
        case iFromDate  = "i_fromdate"
        case iToDate    = "i_todate"
        case iBookingId = "i_bookingid"
        case vFromDate  = "v_fromdate"
        case vToDate    = "v_todate"
        case vBookingId = "v_bookingid"
        case eFromDate  = "e_fromdate"
        case eToDate    = "e_todate"
        case eBookingId = "e_bookingid"
    }

    nonisolated init(
        searchType: Int,
        fromDate: String? = nil, toDate: String? = nil, bookingId: String? = nil,
        hFromDate: String? = nil, hToDate: String? = nil, hBookingId: String? = nil,
        bFromDate: String? = nil, bToDate: String? = nil, bBookingId: String? = nil,
        cFromDate: String? = nil, cToDate: String? = nil, cBookingId: String? = nil,
        iFromDate: String? = nil, iToDate: String? = nil, iBookingId: String? = nil,
        vFromDate: String? = nil, vToDate: String? = nil, vBookingId: String? = nil,
        eFromDate: String? = nil, eToDate: String? = nil, eBookingId: String? = nil
    ) {
        self.searchType = searchType
        self.fromDate   = fromDate
        self.toDate     = toDate
        self.bookingId  = bookingId
        self.hFromDate  = hFromDate
        self.hToDate    = hToDate
        self.hBookingId = hBookingId
        self.bFromDate  = bFromDate
        self.bToDate    = bToDate
        self.bBookingId = bBookingId
        self.cFromDate  = cFromDate
        self.cToDate    = cToDate
        self.cBookingId = cBookingId
        self.iFromDate  = iFromDate
        self.iToDate    = iToDate
        self.iBookingId = iBookingId
        self.vFromDate  = vFromDate
        self.vToDate    = vToDate
        self.vBookingId = vBookingId
        self.eFromDate  = eFromDate
        self.eToDate    = eToDate
        self.eBookingId = eBookingId
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        searchType = try c.decode(Int.self,    forKey: .searchType)
        fromDate   = try c.decodeIfPresent(String.self, forKey: .fromDate)
        toDate     = try c.decodeIfPresent(String.self, forKey: .toDate)
        bookingId  = try c.decodeIfPresent(String.self, forKey: .bookingId)
        hFromDate  = try c.decodeIfPresent(String.self, forKey: .hFromDate)
        hToDate    = try c.decodeIfPresent(String.self, forKey: .hToDate)
        hBookingId = try c.decodeIfPresent(String.self, forKey: .hBookingId)
        bFromDate  = try c.decodeIfPresent(String.self, forKey: .bFromDate)
        bToDate    = try c.decodeIfPresent(String.self, forKey: .bToDate)
        bBookingId = try c.decodeIfPresent(String.self, forKey: .bBookingId)
        cFromDate  = try c.decodeIfPresent(String.self, forKey: .cFromDate)
        cToDate    = try c.decodeIfPresent(String.self, forKey: .cToDate)
        cBookingId = try c.decodeIfPresent(String.self, forKey: .cBookingId)
        iFromDate  = try c.decodeIfPresent(String.self, forKey: .iFromDate)
        iToDate    = try c.decodeIfPresent(String.self, forKey: .iToDate)
        iBookingId = try c.decodeIfPresent(String.self, forKey: .iBookingId)
        vFromDate  = try c.decodeIfPresent(String.self, forKey: .vFromDate)
        vToDate    = try c.decodeIfPresent(String.self, forKey: .vToDate)
        vBookingId = try c.decodeIfPresent(String.self, forKey: .vBookingId)
        eFromDate  = try c.decodeIfPresent(String.self, forKey: .eFromDate)
        eToDate    = try c.decodeIfPresent(String.self, forKey: .eToDate)
        eBookingId = try c.decodeIfPresent(String.self, forKey: .eBookingId)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(searchType, forKey: .searchType)
        try c.encodeIfPresent(fromDate,   forKey: .fromDate)
        try c.encodeIfPresent(toDate,     forKey: .toDate)
        try c.encodeIfPresent(bookingId,  forKey: .bookingId)
        try c.encodeIfPresent(hFromDate,  forKey: .hFromDate)
        try c.encodeIfPresent(hToDate,    forKey: .hToDate)
        try c.encodeIfPresent(hBookingId, forKey: .hBookingId)
        try c.encodeIfPresent(bFromDate,  forKey: .bFromDate)
        try c.encodeIfPresent(bToDate,    forKey: .bToDate)
        try c.encodeIfPresent(bBookingId, forKey: .bBookingId)
        try c.encodeIfPresent(cFromDate,  forKey: .cFromDate)
        try c.encodeIfPresent(cToDate,    forKey: .cToDate)
        try c.encodeIfPresent(cBookingId, forKey: .cBookingId)
        try c.encodeIfPresent(iFromDate,  forKey: .iFromDate)
        try c.encodeIfPresent(iToDate,    forKey: .iToDate)
        try c.encodeIfPresent(iBookingId, forKey: .iBookingId)
        try c.encodeIfPresent(vFromDate,  forKey: .vFromDate)
        try c.encodeIfPresent(vToDate,    forKey: .vToDate)
        try c.encodeIfPresent(vBookingId, forKey: .vBookingId)
        try c.encodeIfPresent(eFromDate,  forKey: .eFromDate)
        try c.encodeIfPresent(eToDate,    forKey: .eToDate)
        try c.encodeIfPresent(eBookingId, forKey: .eBookingId)
    }
}

// MARK: - Agency Statement

struct AgencyStatementRequest: Codable, Sendable {
    let fromDate: String?
    let toDate: String?
    // API spells this "trasactiontype" — preserved exactly to match server key.
    let transactionType: String?

    enum CodingKeys: String, CodingKey {
        case fromDate        = "fromdate"
        case toDate          = "todate"
        case transactionType = "trasactiontype"
    }

    nonisolated init(fromDate: String? = nil, toDate: String? = nil, transactionType: String? = nil) {
        self.fromDate        = fromDate
        self.toDate          = toDate
        self.transactionType = transactionType
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        fromDate        = try c.decodeIfPresent(String.self, forKey: .fromDate)
        toDate          = try c.decodeIfPresent(String.self, forKey: .toDate)
        transactionType = try c.decodeIfPresent(String.self, forKey: .transactionType)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(fromDate,        forKey: .fromDate)
        try c.encodeIfPresent(toDate,          forKey: .toDate)
        try c.encodeIfPresent(transactionType, forKey: .transactionType)
    }
}

// MARK: - Group Fares Request

struct GroupFaresRequest: Codable, Sendable {
    let tripType: String
    let mobileNo: String
    let fromCity: String
    let toCity: String
    let departureDate: String
    let returnDate: String?
    let numAdults: Int
    let numChild: Int
    let numInfant: Int
    let tripPurpose: String?
    let expFare: String?
    let airlineDetailsOnward: String?
    let airlineDetailsReturn: String?
    let remarks: String?

    enum CodingKeys: String, CodingKey {
        case tripType             = "trip_type"
        case mobileNo             = "mobile_no"
        case fromCity, toCity, departureDate, returnDate
        case numAdults, numChild, numInfant
        case tripPurpose          = "trip_purpose"
        case expFare
        case airlineDetailsOnward = "airlineDetailso"
        case airlineDetailsReturn = "airlineDetailsr"
        case remarks
    }

    nonisolated init(
        tripType: String, mobileNo: String, fromCity: String, toCity: String,
        departureDate: String, returnDate: String? = nil,
        numAdults: Int, numChild: Int, numInfant: Int,
        tripPurpose: String? = nil, expFare: String? = nil,
        airlineDetailsOnward: String? = nil, airlineDetailsReturn: String? = nil,
        remarks: String? = nil
    ) {
        self.tripType             = tripType
        self.mobileNo             = mobileNo
        self.fromCity             = fromCity
        self.toCity               = toCity
        self.departureDate        = departureDate
        self.returnDate           = returnDate
        self.numAdults            = numAdults
        self.numChild             = numChild
        self.numInfant            = numInfant
        self.tripPurpose          = tripPurpose
        self.expFare              = expFare
        self.airlineDetailsOnward = airlineDetailsOnward
        self.airlineDetailsReturn = airlineDetailsReturn
        self.remarks              = remarks
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        tripType             = try c.decode(String.self, forKey: .tripType)
        mobileNo             = try c.decode(String.self, forKey: .mobileNo)
        fromCity             = try c.decode(String.self, forKey: .fromCity)
        toCity               = try c.decode(String.self, forKey: .toCity)
        departureDate        = try c.decode(String.self, forKey: .departureDate)
        returnDate           = try c.decodeIfPresent(String.self, forKey: .returnDate)
        numAdults            = try c.decode(Int.self,    forKey: .numAdults)
        numChild             = try c.decode(Int.self,    forKey: .numChild)
        numInfant            = try c.decode(Int.self,    forKey: .numInfant)
        tripPurpose          = try c.decodeIfPresent(String.self, forKey: .tripPurpose)
        expFare              = try c.decodeIfPresent(String.self, forKey: .expFare)
        airlineDetailsOnward = try c.decodeIfPresent(String.self, forKey: .airlineDetailsOnward)
        airlineDetailsReturn = try c.decodeIfPresent(String.self, forKey: .airlineDetailsReturn)
        remarks              = try c.decodeIfPresent(String.self, forKey: .remarks)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(tripType,      forKey: .tripType)
        try c.encode(mobileNo,      forKey: .mobileNo)
        try c.encode(fromCity,      forKey: .fromCity)
        try c.encode(toCity,        forKey: .toCity)
        try c.encode(departureDate, forKey: .departureDate)
        try c.encodeIfPresent(returnDate,           forKey: .returnDate)
        try c.encode(numAdults,     forKey: .numAdults)
        try c.encode(numChild,      forKey: .numChild)
        try c.encode(numInfant,     forKey: .numInfant)
        try c.encodeIfPresent(tripPurpose,          forKey: .tripPurpose)
        try c.encodeIfPresent(expFare,              forKey: .expFare)
        try c.encodeIfPresent(airlineDetailsOnward, forKey: .airlineDetailsOnward)
        try c.encodeIfPresent(airlineDetailsReturn, forKey: .airlineDetailsReturn)
        try c.encodeIfPresent(remarks,              forKey: .remarks)
    }
}

// MARK: - Upload Money Request

struct UploadMoneyRequest: Codable, Sendable {
    let depositType: String
    let payMethod: String
    let transferAmount: String
    let transferDate: String
    let transactionId: String?
    let chequeDrawnBank: String?
    let chequeNo: String?
    let remarks: String?

    enum CodingKeys: String, CodingKey {
        case depositType     = "deposit_type"
        case payMethod       = "pay_method"
        case transferAmount  = "transfer_amount"
        case transferDate    = "transfer_date"
        case transactionId   = "transaction_id"
        case chequeDrawnBank = "cheque_drawn_bank"
        case chequeNo        = "cheque_no"
        case remarks
    }

    nonisolated init(
        depositType: String, payMethod: String, transferAmount: String, transferDate: String,
        transactionId: String? = nil, chequeDrawnBank: String? = nil,
        chequeNo: String? = nil, remarks: String? = nil
    ) {
        self.depositType     = depositType
        self.payMethod       = payMethod
        self.transferAmount  = transferAmount
        self.transferDate    = transferDate
        self.transactionId   = transactionId
        self.chequeDrawnBank = chequeDrawnBank
        self.chequeNo        = chequeNo
        self.remarks         = remarks
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        depositType     = try c.decode(String.self, forKey: .depositType)
        payMethod       = try c.decode(String.self, forKey: .payMethod)
        transferAmount  = try c.decode(String.self, forKey: .transferAmount)
        transferDate    = try c.decode(String.self, forKey: .transferDate)
        transactionId   = try c.decodeIfPresent(String.self, forKey: .transactionId)
        chequeDrawnBank = try c.decodeIfPresent(String.self, forKey: .chequeDrawnBank)
        chequeNo        = try c.decodeIfPresent(String.self, forKey: .chequeNo)
        remarks         = try c.decodeIfPresent(String.self, forKey: .remarks)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(depositType,    forKey: .depositType)
        try c.encode(payMethod,      forKey: .payMethod)
        try c.encode(transferAmount, forKey: .transferAmount)
        try c.encode(transferDate,   forKey: .transferDate)
        try c.encodeIfPresent(transactionId,   forKey: .transactionId)
        try c.encodeIfPresent(chequeDrawnBank, forKey: .chequeDrawnBank)
        try c.encodeIfPresent(chequeNo,        forKey: .chequeNo)
        try c.encodeIfPresent(remarks,         forKey: .remarks)
    }
}

// MARK: - Agent Register

struct AgentRegisterRequest: Codable, Sendable {
    let agentType: String
    let title: String
    let firstName: String
    let lastName: String
    let mobileNo: String
    let officePhoneNo: String?
    let agentEmail: String
    let website: String?
    let designation: String?
    let agentPassword: String
    let confirmPassword: String
    let panNo: String?
    let namePanCard: String?
    let aadharNo: String?
    let agencyName: String
    let serviceTaxNo: String?
    let address: String
    let pinCode: String
    let city: String
    let state: String
    let country: String
    let referralCode: String?
    let saleId: String?
    let adCampaign: String?

    enum CodingKeys: String, CodingKey {
        case agentType       = "agent_type"
        case title, designation, address, city, state, country, website
        case firstName       = "first_name"
        case lastName        = "last_name"
        case mobileNo        = "mobile_no"
        case officePhoneNo   = "office_phone_no"
        case agentEmail      = "agent_email"
        case agentPassword   = "agent_password"
        case confirmPassword = "confirm_pswd"
        case panNo           = "pan_no"
        case namePanCard     = "name_pan_card"
        case aadharNo        = "aadhar_no"
        case agencyName      = "agency_name"
        case serviceTaxNo    = "service_tax_no"
        case pinCode         = "pin_code"
        case referralCode    = "referral_code"
        case saleId          = "sale_id"
        case adCampaign      = "ad_campaign"
    }

    nonisolated init(
        agentType: String, title: String, firstName: String, lastName: String,
        mobileNo: String, officePhoneNo: String? = nil, agentEmail: String,
        website: String? = nil, designation: String? = nil,
        agentPassword: String, confirmPassword: String,
        panNo: String? = nil, namePanCard: String? = nil, aadharNo: String? = nil,
        agencyName: String, serviceTaxNo: String? = nil,
        address: String, pinCode: String, city: String, state: String, country: String,
        referralCode: String? = nil, saleId: String? = nil, adCampaign: String? = nil
    ) {
        self.agentType       = agentType
        self.title           = title
        self.firstName       = firstName
        self.lastName        = lastName
        self.mobileNo        = mobileNo
        self.officePhoneNo   = officePhoneNo
        self.agentEmail      = agentEmail
        self.website         = website
        self.designation     = designation
        self.agentPassword   = agentPassword
        self.confirmPassword = confirmPassword
        self.panNo           = panNo
        self.namePanCard     = namePanCard
        self.aadharNo        = aadharNo
        self.agencyName      = agencyName
        self.serviceTaxNo    = serviceTaxNo
        self.address         = address
        self.pinCode         = pinCode
        self.city            = city
        self.state           = state
        self.country         = country
        self.referralCode    = referralCode
        self.saleId          = saleId
        self.adCampaign      = adCampaign
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        agentType       = try c.decode(String.self, forKey: .agentType)
        title           = try c.decode(String.self, forKey: .title)
        firstName       = try c.decode(String.self, forKey: .firstName)
        lastName        = try c.decode(String.self, forKey: .lastName)
        mobileNo        = try c.decode(String.self, forKey: .mobileNo)
        officePhoneNo   = try c.decodeIfPresent(String.self, forKey: .officePhoneNo)
        agentEmail      = try c.decode(String.self, forKey: .agentEmail)
        website         = try c.decodeIfPresent(String.self, forKey: .website)
        designation     = try c.decodeIfPresent(String.self, forKey: .designation)
        agentPassword   = try c.decode(String.self, forKey: .agentPassword)
        confirmPassword = try c.decode(String.self, forKey: .confirmPassword)
        panNo           = try c.decodeIfPresent(String.self, forKey: .panNo)
        namePanCard     = try c.decodeIfPresent(String.self, forKey: .namePanCard)
        aadharNo        = try c.decodeIfPresent(String.self, forKey: .aadharNo)
        agencyName      = try c.decode(String.self, forKey: .agencyName)
        serviceTaxNo    = try c.decodeIfPresent(String.self, forKey: .serviceTaxNo)
        address         = try c.decode(String.self, forKey: .address)
        pinCode         = try c.decode(String.self, forKey: .pinCode)
        city            = try c.decode(String.self, forKey: .city)
        state           = try c.decode(String.self, forKey: .state)
        country         = try c.decode(String.self, forKey: .country)
        referralCode    = try c.decodeIfPresent(String.self, forKey: .referralCode)
        saleId          = try c.decodeIfPresent(String.self, forKey: .saleId)
        adCampaign      = try c.decodeIfPresent(String.self, forKey: .adCampaign)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(agentType,       forKey: .agentType)
        try c.encode(title,           forKey: .title)
        try c.encode(firstName,       forKey: .firstName)
        try c.encode(lastName,        forKey: .lastName)
        try c.encode(mobileNo,        forKey: .mobileNo)
        try c.encodeIfPresent(officePhoneNo,   forKey: .officePhoneNo)
        try c.encode(agentEmail,      forKey: .agentEmail)
        try c.encodeIfPresent(website,         forKey: .website)
        try c.encodeIfPresent(designation,     forKey: .designation)
        try c.encode(agentPassword,   forKey: .agentPassword)
        try c.encode(confirmPassword, forKey: .confirmPassword)
        try c.encodeIfPresent(panNo,           forKey: .panNo)
        try c.encodeIfPresent(namePanCard,     forKey: .namePanCard)
        try c.encodeIfPresent(aadharNo,        forKey: .aadharNo)
        try c.encode(agencyName,      forKey: .agencyName)
        try c.encodeIfPresent(serviceTaxNo,    forKey: .serviceTaxNo)
        try c.encode(address,         forKey: .address)
        try c.encode(pinCode,         forKey: .pinCode)
        try c.encode(city,            forKey: .city)
        try c.encode(state,           forKey: .state)
        try c.encode(country,         forKey: .country)
        try c.encodeIfPresent(referralCode,    forKey: .referralCode)
        try c.encodeIfPresent(saleId,          forKey: .saleId)
        try c.encodeIfPresent(adCampaign,      forKey: .adCampaign)
    }
}
