import SwiftUI

struct HomeView: View {
    @State private var viewModel: HomeViewModel

    init(authManager: AuthManager) {
        _viewModel = State(initialValue: HomeViewModel(authManager: authManager))
    }

    var body: some View {
        ZStack(alignment: .leading) {
            mainContent
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Dim overlay behind open menu
            Color.black
                .opacity(viewModel.isSideMenuOpen ? 0.45 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 0.25), value: viewModel.isSideMenuOpen)
                .allowsHitTesting(viewModel.isSideMenuOpen)
                .onTapGesture { viewModel.closeSideMenu() }

            // Slide-in drawer
            SideMenuView(viewModel: viewModel)
                .frame(width: 280)
                .offset(x: viewModel.isSideMenuOpen ? 0 : -280)
                .animation(.easeInOut(duration: 0.25), value: viewModel.isSideMenuOpen)
        }
        .navigationBarHidden(true)
        .task {
            await viewModel.checkAndRefreshTokenIfNeeded()
        }
    }

    // MARK: - Main content

    private var mainContent: some View {
        VStack(spacing: 0) {
            topBar
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    greetingCard
                    verticalSection
                }
                .padding(20)
            }
        }
        .background(Color("InputBackground").ignoresSafeArea())
    }

    private var topBar: some View {
        HStack {
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

            Button { /* TODO: notifications */ } label: {
                Image(systemName: "bell")
                    .font(.title3)
                    .foregroundStyle(Color("TextPrimary"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color("CardBackground"))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    private var greetingCard: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color("AccentOrange").opacity(0.15))
                    .frame(width: 52, height: 52)
                Image(systemName: "person.fill")
                    .font(.title3)
                    .foregroundStyle(Color("AccentOrange"))
            }
            VStack(alignment: .leading, spacing: 3) {
                Text("Welcome back,")
                    .font(.caption)
                    .foregroundStyle(Color("TextSecondary"))
                Text(viewModel.agentName)
                    .font(.headline)
                    .foregroundStyle(Color("TextPrimary"))
                if !viewModel.agentEmail.isEmpty {
                    Text(viewModel.agentEmail)
                        .font(.caption)
                        .foregroundStyle(Color("TextSecondary"))
                }
            }
            Spacer()
        }
        .padding(16)
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
    }

    private var verticalSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Book Travel")
                .font(.headline)
                .foregroundStyle(Color("TextPrimary"))

            let tiles: [(icon: String, label: String)] = [
                ("airplane",   "Flights"),
                ("building.2", "Hotels"),
                ("tram",       "Trains"),
                ("bus",        "Buses"),
            ]

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 12
            ) {
                ForEach(tiles, id: \.label) { tile in
                    verticalTile(icon: tile.icon, label: tile.label)
                }
            }
        }
    }

    private func verticalTile(icon: String, label: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 30))
                .foregroundStyle(Color("AccentOrange"))
            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color("TextPrimary"))
            Text("Coming soon")
                .font(.caption2)
                .foregroundStyle(Color("TextSecondary"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 22)
        .background(Color("CardBackground"))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(Color("BorderColor"), lineWidth: 1)
        )
    }
}
