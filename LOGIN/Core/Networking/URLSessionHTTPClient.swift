import Foundation

private struct _ErrorBody: Decodable {
    let message: String?
    let errorDesc: String?
    enum CodingKeys: String, CodingKey {
        case message
        case errorDesc = "ErrorDesc"
    }
}

final class URLSessionHTTPClient: HTTPClientProtocol {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func send<T: Decodable>(_ urlRequest: URLRequest) async throws -> T {
        print("[\(urlRequest.httpMethod ?? "?")] \(urlRequest.url?.absoluteString ?? "unknown URL")")
        if let body = urlRequest.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Request Body: \(bodyString)")
        }

        let (data, response) = try await session.data(for: urlRequest)

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        let rawResponse = String(data: data, encoding: .utf8) ?? "<non-UTF8 data>"
        print("Response [\(http.statusCode)] \(urlRequest.url?.path ?? ""): \(rawResponse)")

        guard http.statusCode != 401 else {
            throw NetworkError.unauthorized
        }
        guard (200..<300).contains(http.statusCode) else {
            // Try to extract a human-readable message from the response body before
            // falling back to the generic HTTP status phrase.
            let bodyMessage = (try? JSONDecoder().decode(_ErrorBody.self, from: data))
                .flatMap { $0.errorDesc ?? $0.message }
            throw NetworkError.serverError(
                bodyMessage ?? HTTPURLResponse.localizedString(forStatusCode: http.statusCode)
            )
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch let decodingError as DecodingError {
            switch decodingError {
            case .typeMismatch(let type, let context):
                print("Decode error — type mismatch: expected \(type) at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)")
            case .valueNotFound(let type, let context):
                print("Decode error — value not found: \(type) at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)")
            case .keyNotFound(let key, let context):
                print("Decode error — key not found: '\(key.stringValue)' at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)")
            case .dataCorrupted(let context):
                print("Decode error — data corrupted at \(context.codingPath.map(\.stringValue).joined(separator: ".")): \(context.debugDescription)")
            @unknown default:
                print("Decode error: \(decodingError)")
            }
            throw NetworkError.decodingFailed(decodingError)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }
}
