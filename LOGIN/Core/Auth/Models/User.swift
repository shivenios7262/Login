import Foundation

struct User: Codable, Equatable, Sendable {
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
    let creditBalance: String?
    let bookingBalance: String?

    var displayName: String {
        [title, firstName, lastName].compactMap { $0 }.joined(separator: " ")
    }

    enum CodingKeys: String, CodingKey {
        case title
        case agentId      = "agent_id"
        case distId       = "dist_id"
        case agentNo      = "agent_no"
        case agencyName   = "agency_name"
        case agentEmail   = "agent_email"
        case agentLogo    = "agent_logo"
        case firstName    = "first_name"
        case lastName     = "last_name"
        case mobileNo     = "mobile_no"
        case creditBalance  = "creditbalance"
        case bookingBalance = "bookingbalance"
    }

    nonisolated init(
        agentId: String?, distId: String?, agentNo: String?,
        agencyName: String?, agentEmail: String?, agentLogo: String?,
        title: String?, firstName: String?, lastName: String?,
        mobileNo: String?, creditBalance: String?, bookingBalance: String?
    ) {
        self.agentId = agentId
        self.distId = distId
        self.agentNo = agentNo
        self.agencyName = agencyName
        self.agentEmail = agentEmail
        self.agentLogo = agentLogo
        self.title = title
        self.firstName = firstName
        self.lastName = lastName
        self.mobileNo = mobileNo
        self.creditBalance = creditBalance
        self.bookingBalance = bookingBalance
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
        creditBalance = try c.decodeIfPresent(String.self, forKey: .creditBalance)
        bookingBalance = try c.decodeIfPresent(String.self, forKey: .bookingBalance)
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encodeIfPresent(agentId,       forKey: .agentId)
        try c.encodeIfPresent(distId,        forKey: .distId)
        try c.encodeIfPresent(agentNo,       forKey: .agentNo)
        try c.encodeIfPresent(agencyName,    forKey: .agencyName)
        try c.encodeIfPresent(agentEmail,    forKey: .agentEmail)
        try c.encodeIfPresent(agentLogo,     forKey: .agentLogo)
        try c.encodeIfPresent(title,         forKey: .title)
        try c.encodeIfPresent(firstName,     forKey: .firstName)
        try c.encodeIfPresent(lastName,      forKey: .lastName)
        try c.encodeIfPresent(mobileNo,      forKey: .mobileNo)
        try c.encodeIfPresent(creditBalance, forKey: .creditBalance)
        try c.encodeIfPresent(bookingBalance, forKey: .bookingBalance)
    }
}
