import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingFailed(Error)
    case serverError(String)
    case unauthorized
    case sessionExpired
    case noAppToken

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return String(localized: "Invalid URL")
        case .noData:
            return String(localized: "No data received from server")
        case .decodingFailed(let error):
            return error.localizedDescription
        case .serverError(let message):
            return message
        case .unauthorized:
            return String(localized: "Unauthorized. Please log in again.")
        case .sessionExpired:
            return String(localized: "Your session has expired. Please log in again.")
        case .noAppToken:
            return String(localized: "Application token unavailable")
        }
    }
}
