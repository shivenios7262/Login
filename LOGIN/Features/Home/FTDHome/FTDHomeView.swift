import SwiftUI

// MARK: - FTDHomeView
// MakeMyTrip-inspired redesign of the home screen.
// Routing: see RootView.swift — comment-toggle between HomeView and FTDHomeView.

struct FTDHomeView: View {
    @State private var viewModel: FTDHomeViewModel

    init(authManager: AuthManager) {
        _viewModel = State(initialValue: FTDHomeViewModel(authManager: authManager))
    }

    var body: some View {
        ZStack(alignment: .leading) {
            tabLayout
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Dim overlay behind open side menu
            Color.black
                .opacity(viewModel.isSideMenuOpen ? 0.45 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.25), value: viewModel.isSideMenuOpen)
                .allowsHitTesting(viewModel.isSideMenuOpen)
                .onTapGesture { viewModel.closeSideMenu() }

            // Slide-in drawer
            FTDSideMenuView(viewModel: viewModel)
                .frame(width: 280)
                .offset(x: viewModel.isSideMenuOpen ? 0 : -280)
                .animation(.easeInOut(duration: 0.25), value: viewModel.isSideMenuOpen)
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.checkAndRefreshTokenIfNeeded()
        }
    }

    // MARK: - Tab Layout

    private var tabLayout: some View {
        VStack(spacing: 0) {
            tabPageContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            bottomTabBar
        }
    }

    @ViewBuilder
    private var tabPageContent: some View {
        switch viewModel.selectedTab {
        case .home:       homeScreen
        case .myTrips:    placeholderScreen(title: "My Trips",    icon: "bag.fill")
        case .wishlists:  placeholderScreen(title: "Wishlists",   icon: "heart.fill")
        case .creditCard: placeholderScreen(title: "Credit Card", icon: "creditcard.fill")
        }
    }

    // MARK: - Home Screen

    private var homeScreen: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    aiSearchBar
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    categoryPanel
                    offersSection
                        .padding(.top, 20)
                    Spacer(minLength: 24)
                }
            }
            .background(Color("InputBackground"))
        }
        .background(Color("InputBackground"))
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack(spacing: 10) {
            Button { viewModel.toggleSideMenu() } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundStyle(Color("TextPrimary"))
            }

            Spacer()

            HStack(spacing: 4) {
                Image(systemName: "airplane")
                    .fontWeight(.bold)
                    .foregroundStyle(Color("AccentOrange"))
                Text("FTD")
                    .font(.headline)
                    .fontWeight(.black)
                    .foregroundStyle(Color("AccentOrange"))
            }

            Spacer()

            // Shows live creditBalance from User model; falls back to a label
            Button { /* TODO: open agent wallet */ } label: {
                Text(viewModel.creditBalanceLabel)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("AccentOrange").opacity(0.12))
                    .foregroundStyle(Color("AccentOrange"))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color("AccentOrange").opacity(0.4), lineWidth: 1))
            }

            Button { /* TODO: open B2B portal */ } label: {
                Text("B2B")
                    .font(.caption)
                    .fontWeight(.bold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color("AccentTeal").opacity(0.12))
                    .foregroundStyle(Color("AccentTeal"))
                    .clipShape(Capsule())
                    .overlay(Capsule().stroke(Color("AccentTeal").opacity(0.4), lineWidth: 1))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("CardBackground"))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    // MARK: - AI Search Bar

    private var aiSearchBar: some View {
        Button { /* TODO: open AI travel assistant */ } label: {
            HStack(spacing: 10) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color("AccentOrange"))
                    .font(.subheadline)

                Text("Ask FTD about travel options...")
                    .font(.subheadline)
                    .foregroundStyle(Color("TextSecondary"))
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: 4) {
                    Image(systemName: "waveform")
                        .font(.caption)
                    Text("Speak")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color("AccentOrange").opacity(0.1))
                .foregroundStyle(Color("AccentOrange"))
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color("AccentOrange").opacity(0.3), lineWidth: 1))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Color("CardBackground"))
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay(RoundedRectangle(cornerRadius: 24).stroke(Color("BorderColor"), lineWidth: 1))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Category Panel (primary row + secondary grid on one card)

    private var categoryPanel: some View {
        VStack(spacing: 0) {
            primaryCategoryRow
            Divider()
                .padding(.horizontal, 12)
            secondaryCategoryGrid
        }
        .background(Color("CardBackground"))
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    // Four tiles filling the full width equally
    private var primaryCategoryRow: some View {
        HStack(spacing: 0) {
            ForEach(ServiceCategory.primaryCategories) { category in
                primaryTile(category)
            }
        }
        .padding(.vertical, 4)
    }

    private func primaryTile(_ category: ServiceCategory) -> some View {
        Button { /* TODO: navigate to category */ } label: {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 34))
                    .foregroundStyle(Color("AccentOrange"))
                    .frame(height: 42)
                Text(category.label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color("TextPrimary"))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .buttonStyle(.plain)
    }

    // Twelve tiles in a 4-column grid
    private var secondaryCategoryGrid: some View {
        VStack(spacing: 0) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 4),
                spacing: 0
            ) {
                ForEach(ServiceCategory.secondaryCategories) { category in
                    secondaryTile(category)
                }
            }

            // Collapse affordance — matches the up-chevron in the design reference
            Image(systemName: "chevron.up")
                .font(.caption2)
                .foregroundStyle(Color("TextSecondary"))
                .padding(.vertical, 8)
        }
    }

    private func secondaryTile(_ category: ServiceCategory) -> some View {
        Button { /* TODO: navigate to category */ } label: {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: 6) {
                    Image(systemName: category.icon)
                        .font(.system(size: 24))
                        .foregroundStyle(Color("AccentOrange"))
                        .frame(height: 30)
                    Text(category.label)
                        .font(.system(size: 10, weight: .medium))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color("TextPrimary"))
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .padding(.horizontal, 4)

                if let badge = category.badge {
                    Text(badge)
                        .font(.system(size: 7, weight: .bold))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .offset(x: -4, y: 4)
                }
            }
            .overlay(Rectangle().stroke(Color("BorderColor").opacity(0.4), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Offers Section

    private var offersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            offersHeader
                .padding(.horizontal, 16)
            offerFilterTabs
            offerCards
        }
    }

    private var offersHeader: some View {
        HStack {
            Text("Offers")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundStyle(Color("TextPrimary"))
            Spacer()
            Button { /* TODO: navigate to all offers */ } label: {
                HStack(spacing: 2) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundStyle(Color("AccentOrange"))
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color("AccentOrange"))
                }
            }
        }
    }

    private var offerFilterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(OfferFilter.allCases) { filter in
                    offerFilterChip(filter)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private func offerFilterChip(_ filter: OfferFilter) -> some View {
        let isSelected = viewModel.selectedOfferFilter == filter
        return Button {
            viewModel.selectedOfferFilter = filter
        } label: {
            Text(filter.title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(isSelected ? Color("AccentOrange") : Color("CardBackground"))
                .foregroundStyle(isSelected ? Color.white : Color("TextSecondary"))
                .clipShape(Capsule())
                .overlay {
                    if !isSelected {
                        Capsule().stroke(Color("BorderColor"), lineWidth: 1)
                    }
                }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: viewModel.selectedOfferFilter)
    }

    private var offerCards: some View {
        // Placeholder gradient cards — swap LinearGradient for AsyncImage once offer API is wired
        let configs: [(label: String, tag: String, colors: [Color])] = [
            ("Break Free\nTravel Sale", "FLIGHTS",  [Color("AccentOrange").opacity(0.8), .red.opacity(0.5)]),
            ("Summer\nEscape Deals",   "HOTELS",   [.blue.opacity(0.6),                 .purple.opacity(0.5)]),
            ("Holiday\nPackages",      "HOLIDAYS", [.green.opacity(0.55),               .teal.opacity(0.5)]),
            ("Rail\nSaver Pass",       "RAILS",    [Color("AccentTeal").opacity(0.7),   .blue.opacity(0.4)]),
        ]

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(configs.indices, id: \.self) { i in
                    offerCard(headline: configs[i].label, tag: configs[i].tag, colors: configs[i].colors)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 4)
        }
    }

    private func offerCard(headline: String, tag: String, colors: [Color]) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 200, height: 120)
            VStack(alignment: .leading, spacing: 6) {
                Text(tag)
                    .font(.system(size: 9, weight: .bold))
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.white.opacity(0.9))
                    .foregroundStyle(Color("AccentOrange"))
                    .clipShape(Capsule())
                Text(headline)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }
            .padding(12)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }

    // MARK: - Placeholder Screen

    private func placeholderScreen(title: String, icon: String) -> some View {
        VStack(spacing: 12) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundStyle(Color("TextSecondary").opacity(0.4))
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(Color("TextSecondary"))
            Text("Coming soon")
                .font(.subheadline)
                .foregroundStyle(Color("TextSecondary").opacity(0.6))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color("InputBackground"))
    }

    // MARK: - Bottom Tab Bar

    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            ForEach(FTDHomeTab.allCases) { tab in
                tabBarItem(tab)
            }
        }
        .background(Color("CardBackground"))
        .overlay(alignment: .top) { Divider() }
        .shadow(color: .black.opacity(0.06), radius: 6, y: -2)
    }

    private func tabBarItem(_ tab: FTDHomeTab) -> some View {
        let isActive = viewModel.selectedTab == tab
        return Button {
            viewModel.selectedTab = tab
        } label: {
            VStack(spacing: 4) {
                Image(systemName: isActive ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 22))
                    .foregroundStyle(isActive ? Color("AccentOrange") : Color("TextSecondary"))
                Text(tab.title)
                    .font(.system(size: 10, weight: isActive ? .semibold : .regular))
                    .foregroundStyle(isActive ? Color("AccentOrange") : Color("TextSecondary"))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: viewModel.selectedTab)
    }
}
