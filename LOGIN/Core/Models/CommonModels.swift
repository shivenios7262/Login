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
