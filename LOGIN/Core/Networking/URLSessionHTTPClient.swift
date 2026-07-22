import Foundation

final class URLSessionHTTPClient: HTTPClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send<T: Decodable>(_ urlRequest: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: urlRequest)
        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }
        guard http.statusCode != 401 else {
            throw NetworkError.unauthorized
        }
        guard (200..<300).contains(http.statusCode) else {
            throw NetworkError.serverError(
                HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
            )
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
