import Foundation
import Observation

@Observable
@MainActor
final class PrivacyPolicyViewModel {

    enum LoadState {
        case loading
        case loaded(PrivacyData)
        case failure(String)
    }

    private(set) var state: LoadState = .loading
    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func load() async {
        state = .loading
        do {
            let data = try await authManager.fetchPrivacyPolicy()
            state = .loaded(data)
        } catch {
            state = .failure(error.localizedDescription)
        }
    }
}
