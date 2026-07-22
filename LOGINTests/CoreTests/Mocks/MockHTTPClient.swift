import Foundation
@testable import LOGIN

final class MockHTTPClient: HTTPClientProtocol, @unchecked Sendable {
    private var stubbedData: [String: Data] = [:]
    private var stubbedErrors: [String: Error] = [:]
    private(set) var requestLog: [URLRequest] = []

    func stub<T: Encodable>(path: String, response: T) {
        stubbedData[path] = try? JSONEncoder().encode(response)
    }

    func stub(path: String, error: Error) {
        stubbedErrors[path] = error
    }

    func send<T: Decodable>(_ urlRequest: URLRequest) async throws -> T {
        requestLog.append(urlRequest)
        let path = urlRequest.url?.path() ?? ""

        if let error = stubbedErrors[path] { throw error }
        guard let data = stubbedData[path] else { throw NetworkError.noData }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
