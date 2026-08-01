import Foundation
import Observation

@Observable
@MainActor
final class ProfileViewModel: ProfileProvider {
    private(set) var profile: AgentProfileData? = nil
    private(set) var isLoadingProfile = false
    private(set) var profileError: String? = nil

    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
    }

    func fetchProfile() async {
        isLoadingProfile = true
        profileError = nil
        defer { isLoadingProfile = false }
        do {
            let response = try await authManager.fetchProfile()
            if response.status { profile = response.data }
            else { profileError = response.message ?? String(localized: "Failed to load profile.") }
        } catch let e as NetworkError { profileError = e.errorDescription
        } catch { profileError = error.localizedDescription }
    }
}
