import Foundation

struct APIRequest {
    let path: String
    let method: HTTPMethod
    let body: Data?
    let requiresAppToken: Bool
    let requiresBearerToken: Bool
}
