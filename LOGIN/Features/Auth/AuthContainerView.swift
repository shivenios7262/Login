import SwiftUI

struct AuthContainerView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(AppRouter.self)   private var router
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selectedTab: AuthTab = .signIn

    private enum Layout {
        // design.md §2a (iPad adaptive): promoted to DesignTokens.Layout — shared across all screens
        // static let maxWidthRegular: CGFloat = 430
        static let maxWidthRegular: CGFloat          = DesignTokens.Layout.maxWidthRegular

        // design.md §4 (magic numbers): 34pt logo top offset, mapped to DesignTokens.Spacing.xxxl (36) is closest;
        // keeping exact value here until a semantic token is confirmed with designer
        static let logoTopPadding: CGFloat           = 34

        // design.md §4 (magic numbers): mapped to DesignTokens.Size
        // static let logoWidth: CGFloat = 100//120
        static let logoWidth: CGFloat                = DesignTokens.Size.logoWidth

        static let tabContainerCornerRadius: CGFloat = DesignTokens.Radius.button  // ✅
        static let tabItemCornerRadius: CGFloat      = DesignTokens.Radius.field   // ✅

        // design.md §4 (magic numbers): mapped to DesignTokens.Size
        // static let tabItemHeight: CGFloat = 40
        static let tabItemHeight: CGFloat            = DesignTokens.Size.tabItemHeight

        // design.md §4 (magic numbers): Spacing.xxs == 2
        // static let tabInset: CGFloat = 2
        static let tabInset: CGFloat                 = DesignTokens.Spacing.xxs

        // design.md §4: dead constant — only referenced in commented-out code below (lines ~38)
        // static let backgroundMapHeightRatio: CGFloat = 0.35
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
                .containerRelativeFrame(.vertical, alignment: .top) { height, _ in height * (440.0 / 932.0) }
                .frame(maxWidth: .infinity, alignment: .top)
                .clipped()
                .opacity(0.95)
                .ignoresSafeArea(edges: .top)
                .padding(.top, 0)
                .padding(.horizontal, 4)
           

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
        // design.md §2a (SwiftUI only): .navigationBarHidden deprecated in iOS 16+ — replaced with .toolbar modifier
        // .navigationBarHidden(true)
        .toolbar(.hidden, for: .navigationBar)
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

            // design.md §2a (localization): hardcoded string replaced — key must exist in .xcstrings catalog
            // Text("Welcome to FTD Travel")
            Text(String(localized: "auth.welcome.title"))
                // .title is 28pt semibold in SF Pro and scales with Dynamic Type — no fixed-size token needed
                .font(.title.weight(.semibold))
                //.fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextPrimary)
                .padding(.top, DesignTokens.Spacing.md)

            // design.md §2a (localization): hardcoded string replaced — key must exist in .xcstrings catalog
            // Text("Your next journey begins here")
            Text(String(localized: "auth.welcome.subtitle"))
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
                                .stroke(selectedTab == tab ? Color.ftdAccentOrange : Color.clear, lineWidth: 1.0)
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
                .stroke(Color.ftdAccentOrangeAlpha/*.opacity(0.45)*/, lineWidth: 1)
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

    // design.md §2b (architecture): navigation decision — should move to an AuthContainerViewModel/coordinator
    // Tracked: AuthContainerView needs a ViewModel to own tab-switch logic; keeping here temporarily
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

