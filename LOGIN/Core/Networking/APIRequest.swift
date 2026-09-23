import Foundation

struct APIRequest {
    let path: String
    let method: HTTPMethod
    let body: Data?
    let contentType: String
    let requiresAppToken: Bool
    let requiresBearerToken: Bool

    nonisolated init(
        path: String,
        method: HTTPMethod,
        body: Data?,
        contentType: String = "application/json",
        requiresAppToken: Bool,
        requiresBearerToken: Bool
    ) {
        self.path = path
        self.method = method
        self.body = body
        self.contentType = contentType
        self.requiresAppToken = requiresAppToken
        self.requiresBearerToken = requiresBearerToken
    }
}
