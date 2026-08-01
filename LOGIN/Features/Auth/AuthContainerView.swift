import SwiftUI

struct AuthContainerView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AppRouter.self)   private var router
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selectedTab: AuthTab = .signIn

    private enum Layout {
        static let maxWidthRegular: CGFloat         = 430
        static let logoTopPadding: CGFloat          = 34
        static let logoWidth: CGFloat               = 100//120
        static let tabContainerCornerRadius: CGFloat = DesignTokens.Radius.button
        static let tabItemCornerRadius: CGFloat     = DesignTokens.Radius.field
        static let tabItemHeight: CGFloat           = 40
        static let tabInset: CGFloat                = 2
        static let backgroundMapHeightRatio: CGFloat = 0.35
    }

    enum AuthTab: CaseIterable {
        case signIn, signUp

        var label: LocalizedStringKey {
            switch self {
            case .signIn: "Sign In"
            case .signUp: "Sign Up"
            }
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.ftdCardBackground.ignoresSafeArea()

            Image("dottedMap")
                .resizable()
                .scaledToFill()
//                .frame(maxWidth: .infinity)
//                .frame(height: UIScreen.main.bounds.height * Layout.backgroundMapHeightRatio)
                .containerRelativeFrame(.vertical) { height, _ in height * 0.5 }
                .frame(maxWidth: .infinity, alignment: .top)
                .clipped()
                .opacity(0.95)
                .ignoresSafeArea(edges: .top)
            
           

            ScrollView {
                VStack(spacing: 0) {
                    authHeader
                    tabSwitcher
                        .padding(.top, DesignTokens.Spacing.xxl)
                        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
                    tabContent
                        .padding(.top, DesignTokens.Spacing.xxl)
                }
                .frame(maxWidth: sizeClass == .regular ? Layout.maxWidthRegular : .infinity)
                .frame(maxWidth: .infinity)
            }
            .background(Color.clear)
            .scrollContentBackground(.hidden)
        }
        .navigationBarHidden(true)
        .background(Color.ftdCardBackground.ignoresSafeArea())
    }

    // MARK: - Header

    private var authHeader: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: Layout.logoWidth)
                .padding(.top, Layout.logoTopPadding)

            Text("Welcome to FTD Travel")
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(Color.ftdTextPrimary)
                .padding(.top, DesignTokens.Spacing.md)

            Text("Your next journey begins here")
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        .padding(.bottom, DesignTokens.Spacing.sm)
    }

    // MARK: - Pill Tab Switcher

    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(AuthTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: DesignTokens.Animation.standard)) {
                        selectedTab = tab
                    }
                } label: {
                    Text(tab.label)
                        .font(.subheadline)
                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                        .foregroundStyle(selectedTab == tab ? Color.ftdAccentOrange : Color.ftdTextPrimary)
                        .frame(maxWidth: .infinity)
                        .frame(height: Layout.tabItemHeight)
                        .background(selectedTab == tab ? Color.ftdCardBackground : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: Layout.tabItemCornerRadius))
                        .overlay(
                            RoundedRectangle(cornerRadius: Layout.tabItemCornerRadius)
                                .stroke(selectedTab == tab ? Color.ftdAccentOrange : Color.clear, lineWidth: 1.5)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(Layout.tabInset)
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: Layout.tabContainerCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: Layout.tabContainerCornerRadius)
                .stroke(Color.ftdAccentOrange.opacity(0.45), lineWidth: 1)
        )
    }

    // MARK: - Tab Content

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case .signIn:
            SignInView(authManager: authManager, router: router)
        case .signUp:
            SignUpView(authManager: authManager, onSuccess: switchToSignIn)
        }
    }

    // MARK: - Actions

    private func switchToSignIn() {
        withAnimation(.easeInOut(duration: DesignTokens.Animation.standard)) {
            selectedTab = .signIn
        }
    }
}

// MARK: - Preview
/*
#Preview("Sign In tab") {
    struct PreviewKeychain: KeychainServiceProtocol {
        func save(key: KeychainKey, value: String) {}
        @discardableResult func delete(key: KeychainKey) -> Bool { false }
        func read(key: KeychainKey) -> String? { nil }
    }
    struct PreviewHTTPClient: HTTPClientProtocol {
        func send<T: Decodable>(_ urlRequest: URLRequest) async throws -> T {
            throw URLError(.notConnectedToInternet)
        }
    }
    let keychain = PreviewKeychain()
    let apiClient = APIClient(
        httpClient: PreviewHTTPClient(),
        baseURL: URL(string: "https://preview.example.com")!,
        keychain: keychain,
        appCredentials: AppCredentials(appType: 1, appUser: "", appPassword: "", appVersion: "1.0", persistAppToken: false)
    )
    let authManager = AuthManager(apiClient: apiClient, keychain: keychain)
    let router = AppRouter()
    return AuthContainerView()
        .environment(authManager)
        .environment(router)
}*/

