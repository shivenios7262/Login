import SwiftUI

struct AuthContainerView: View {
    @Environment(AuthManager.self) private var authManager
    @Environment(\.horizontalSizeClass) private var sizeClass
    @State private var selectedTab: AuthTab = .signIn

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
            Color("CardBackground").ignoresSafeArea()

            Image("dottedMap")
                .resizable()
                .scaledToFill()
                .containerRelativeFrame(.vertical) { height, _ in height * 0.35 }
                .frame(maxWidth: .infinity, alignment: .top)
                .clipped()
                .opacity(0.95)
                .ignoresSafeArea(edges: .top)

            ScrollView {
                VStack(spacing: 0) {
                    authHeader
                    tabSwitcher
                        .padding(.top, 24)
                    Divider()
                        .padding(.top, 0)

                    switch selectedTab {
                    case .signIn:
                        SignInView(authManager: authManager)
                            .padding(.top, 20)
                    case .signUp:
                        SignUpView()
                            .padding(.top, 20)
                    }
                }
                .frame(maxWidth: sizeClass == .regular ? 430 : .infinity)
                .frame(maxWidth: .infinity)
            }
        }
        .navigationBarHidden(true)
        .background(Color("CardBackground").ignoresSafeArea())
    }

    // MARK: - Subviews

    private var authHeader: some View {
        VStack(alignment: .leading, spacing: 4) {
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 120)
                .padding(.top, 56)

            Text("Welcome to FTD Travel")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(Color("TextPrimary"))
                .padding(.top, 12)
            Text("Your next journey begins here")
                .font(.subheadline)
                .foregroundStyle(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 24)
        .padding(.bottom, 8)
    }

    private var tabSwitcher: some View {
        HStack(spacing: 0) {
            ForEach(AuthTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(tab.label)
                            .fontWeight(selectedTab == tab ? .semibold : .regular)
                            .foregroundStyle(
                                selectedTab == tab ? Color("AccentOrange") : Color("TextSecondary")
                            )
                        Rectangle()
                            .frame(height: 2)
                            .foregroundStyle(
                                selectedTab == tab ? Color("AccentOrange") : Color.clear
                            )
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
}
