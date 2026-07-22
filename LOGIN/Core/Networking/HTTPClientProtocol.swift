import Foundation

protocol HTTPClientProtocol: Sendable {
    func send<T: Decodable>(_ urlRequest: URLRequest) async throws -> T
}
