import Foundation

// MARK: - Generic API Response

struct GenericAPIResponse: Codable, Sendable {
    let status: Bool
    let message: String?
    let errorCode: Int?
    let errorDesc: String?

    var serverMessage: String? { message ?? errorDesc }

    enum CodingKeys: String, CodingKey {
        case status, message
        case errorCode = "ErrorCode"
        case errorDesc = "ErrorDesc"
    }

    nonisolated init(status: Bool, message: String?, errorCode: Int? = nil, errorDesc: String? = nil) {
        self.status    = status
        self.message   = message
        self.errorCode = errorCode
        self.errorDesc = errorDesc
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        status    = try c.decode(Bool.self, forKey: .status)
        message   = try c.decodeIfPresent(String.self, forKey: .message)
        errorCode = try c.decodeIfPresent(Int.self,    forKey: .errorCode)
        errorDesc = try c.decodeIfPresent(String.self, forKey: .errorDesc)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(message,   forKey: .message)
        try c.encodeIfPresent(errorCode, forKey: .errorCode)
        try c.encodeIfPresent(errorDesc, forKey: .errorDesc)
    }
}

// MARK: - Forgot Password

struct ForgotPasswordRequest: Codable, Sendable {
    let email: String
    let agentNo: String
    let password: String
    let passconf: String

    enum CodingKeys: String, CodingKey {
        case email
        case agentNo = "agent_no"
        case password
        case passconf
    }

    nonisolated init(email: String, agentNo: String, password: String, passconf: String) {
        self.email    = email
        self.agentNo  = agentNo
        self.password = password
        self.passconf = passconf
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c    = try decoder.container(keyedBy: CodingKeys.self)
        email    = try c.decode(String.self, forKey: .email)
        agentNo  = try c.decode(String.self, forKey: .agentNo)
        password = try c.decode(String.self, forKey: .password)
        passconf = try c.decode(String.self, forKey: .passconf)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(email,    forKey: .email)
        try c.encode(agentNo,  forKey: .agentNo)
        try c.encode(password, forKey: .password)
        try c.encode(passconf, forKey: .passconf)
    }
}

// MARK: - Shared Booking Detail Request

// Used by all service booking-detail endpoints: flight, bus, cab, hotel, insurance, visa, esim.
struct UniqueRefNoRequest: Codable, Sendable {
    let uniqueRefNo: String

    enum CodingKeys: String, CodingKey {
        case uniqueRefNo = "uniquerefno"
    }

    nonisolated init(uniqueRefNo: String) {
        self.uniqueRefNo = uniqueRefNo
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        uniqueRefNo = try c.decode(String.self, forKey: .uniqueRefNo)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(uniqueRefNo, forKey: .uniqueRefNo)
    }
}

// MARK: - Shared Modify Eticket Request

// Used by flight, hotel, insurance, visa, esim modify-eticket endpoints.
struct ModifyEticketRequest: Codable, Sendable {
    let uniqueRefNo: String
    let amount: Double

    enum CodingKeys: String, CodingKey {
        case uniqueRefNo = "uniquerefno"
        case amount
    }

    nonisolated init(uniqueRefNo: String, amount: Double) {
        self.uniqueRefNo = uniqueRefNo
        self.amount      = amount
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        uniqueRefNo = try c.decode(String.self, forKey: .uniqueRefNo)
        amount      = try c.decode(Double.self, forKey: .amount)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(uniqueRefNo, forKey: .uniqueRefNo)
        try c.encode(amount,      forKey: .amount)
    }
}

// MARK: - Bus / Cab Modify Eticket Request

// Bus and cab modify-eticket endpoints include an additional busrefno field.
struct BusModifyEticketRequest: Codable, Sendable {
    let uniqueRefNo: String
    let busRefNo: String
    let amount: Double

    enum CodingKeys: String, CodingKey {
        case uniqueRefNo = "uniquerefno"
        case busRefNo    = "busrefno"
        case amount
    }

    nonisolated init(uniqueRefNo: String, busRefNo: String, amount: Double) {
        self.uniqueRefNo = uniqueRefNo
        self.busRefNo    = busRefNo
        self.amount      = amount
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        uniqueRefNo = try c.decode(String.self, forKey: .uniqueRefNo)
        busRefNo    = try c.decode(String.self, forKey: .busRefNo)
        amount      = try c.decode(Double.self, forKey: .amount)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(uniqueRefNo, forKey: .uniqueRefNo)
        try c.encode(busRefNo,    forKey: .busRefNo)
        try c.encode(amount,      forKey: .amount)
    }
}

// MARK: - State / Country

struct StateItem: Codable, Sendable, Hashable {
    let id: String
    let stateCode: String
    let name: String

    enum CodingKeys: String, CodingKey {
        case id, name
        case stateCode = "state_code"
    }

    nonisolated init(id: String, stateCode: String, name: String) {
        self.id        = id
        self.stateCode = stateCode
        self.name      = name
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c     = try decoder.container(keyedBy: CodingKeys.self)
        id        = try c.decode(String.self, forKey: .id)
        stateCode = try c.decode(String.self, forKey: .stateCode)
        name      = try c.decode(String.self, forKey: .name)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,        forKey: .id)
        try c.encode(stateCode, forKey: .stateCode)
        try c.encode(name,      forKey: .name)
    }
}

struct CountryItem: Codable, Sendable {
    let id: String
    let name: String
    let iso2: String
    let phoneCode: String
    let flagImage: String?
    let states: [StateItem]

    static let unselected = CountryItem(id: "", name: "", iso2: "", phoneCode: "", flagImage: nil, states: [])

    enum CodingKeys: String, CodingKey {
        case id, name, states
        case iso2      = "iso2"
        case phoneCode = "phone_code"
        case flagImage = "flag_image"
    }

    nonisolated init(id: String, name: String, iso2: String, phoneCode: String, flagImage: String?, states: [StateItem]) {
        self.id        = id
        self.name      = name
        self.iso2      = iso2
        self.phoneCode = phoneCode
        self.flagImage = flagImage
        self.states    = states
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c      = try decoder.container(keyedBy: CodingKeys.self)
        id        = try c.decode(String.self,       forKey: .id)
        name      = try c.decode(String.self,       forKey: .name)
        iso2      = try c.decode(String.self,       forKey: .iso2)
        phoneCode = try c.decode(String.self,       forKey: .phoneCode)
        flagImage = try c.decodeIfPresent(String.self, forKey: .flagImage)
        states    = try c.decode([StateItem].self,  forKey: .states)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(id,        forKey: .id)
        try c.encode(name,      forKey: .name)
        try c.encode(iso2,      forKey: .iso2)
        try c.encode(phoneCode, forKey: .phoneCode)
        try c.encodeIfPresent(flagImage, forKey: .flagImage)
        try c.encode(states,    forKey: .states)
    }
}

extension CountryItem: Hashable {
    nonisolated static func == (lhs: CountryItem, rhs: CountryItem) -> Bool { lhs.id == rhs.id }
    nonisolated func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

struct CountriesResponse: Codable, Sendable {
    let status: Bool
    let message: String?
    let errorCode: Int?
    let errorDesc: String?
    let data: [CountryItem]?

    var serverMessage: String? { message ?? errorDesc }

    enum CodingKeys: String, CodingKey {
        case status, message, data
        case errorCode = "ErrorCode"
        case errorDesc = "ErrorDesc"
    }

    nonisolated init(status: Bool, message: String?, errorCode: Int?, errorDesc: String?, data: [CountryItem]?) {
        self.status    = status
        self.message   = message
        self.errorCode = errorCode
        self.errorDesc = errorDesc
        self.data      = data
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c     = try decoder.container(keyedBy: CodingKeys.self)
        status    = try c.decode(Bool.self,            forKey: .status)
        message   = try c.decodeIfPresent(String.self, forKey: .message)
        errorCode = try c.decodeIfPresent(Int.self,    forKey: .errorCode)
        errorDesc = try c.decodeIfPresent(String.self, forKey: .errorDesc)
        data      = try c.decodeIfPresent([CountryItem].self, forKey: .data)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(status, forKey: .status)
        try c.encodeIfPresent(message,   forKey: .message)
        try c.encodeIfPresent(errorCode, forKey: .errorCode)
        try c.encodeIfPresent(errorDesc, forKey: .errorDesc)
        try c.encodeIfPresent(data,      forKey: .data)
    }
}

// MARK: - Contact

struct ContactRequest: Codable, Sendable {
    let name: String
    let email: String
    let phone: String
    let message: String

    enum CodingKeys: String, CodingKey { case name, email, phone, message }

    nonisolated init(name: String, email: String, phone: String, message: String) {
        self.name    = name
        self.email   = email
        self.phone   = phone
        self.message = message
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c   = try decoder.container(keyedBy: CodingKeys.self)
        name    = try c.decode(String.self, forKey: .name)
        email   = try c.decode(String.self, forKey: .email)
        phone   = try c.decode(String.self, forKey: .phone)
        message = try c.decode(String.self, forKey: .message)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(name,    forKey: .name)
        try c.encode(email,   forKey: .email)
        try c.encode(phone,   forKey: .phone)
        try c.encode(message, forKey: .message)
    }
}

// MARK: - Privacy Policy

struct PrivacyResponse: Codable, Sendable {
    let status: Bool
    let message: String?
    let data: PrivacyData?

    enum CodingKeys: String, CodingKey { case status, message, data }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        status  = try c.decode(Bool.self,           forKey: .status)
        message = try c.decodeIfPresent(String.self, forKey: .message)
        data    = try c.decodeIfPresent(PrivacyData.self, forKey: .data)
    }
}

struct PrivacyData: Codable, Sendable {
    let pageTitle: String?
    let pageDescription: String?

    enum CodingKeys: String, CodingKey {
        case pageTitle       = "page_title"
        case pageDescription = "page_description"
    }

    nonisolated init(from decoder: any Decoder) throws {
        let c        = try decoder.container(keyedBy: CodingKeys.self)
        pageTitle    = try c.decodeIfPresent(String.self, forKey: .pageTitle)
        pageDescription = try c.decodeIfPresent(String.self, forKey: .pageDescription)
    }
}

// MARK: - Terms & Conditions

struct TermsResponse: Codable, Sendable {
    let status: Bool
    let message: String?
    let data: PrivacyData?         // identical schema to PrivacyData

    enum CodingKeys: String, CodingKey { case status, message, data }

    nonisolated init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        status  = try c.decode(Bool.self,            forKey: .status)
        message = try c.decodeIfPresent(String.self, forKey: .message)
        data    = try c.decodeIfPresent(PrivacyData.self, forKey: .data)
    }
}
