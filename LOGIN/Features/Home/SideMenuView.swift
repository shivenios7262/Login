import SwiftUI

struct SideMenuView: View {
    var viewModel: HomeViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            profileHeader
            Divider()
                .background(Color.white.opacity(0.15))

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(SideMenuItem.allCases) { item in
                        menuRow(item)
                    }
                }
                .padding(.top, 8)
            }

            Divider()
                .background(Color.white.opacity(0.15))

            logoutButton
        }
        .frame(maxHeight: .infinity)
        .background(Color("SideMenuBackground"))
        .ignoresSafeArea(edges: .vertical)
    }

    // MARK: - Subviews

    private var profileHeader: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.15))
                    .frame(width: 60, height: 60)
                Image(systemName: "person.fill")
                    .font(.title)
                    .foregroundStyle(.white)
            }
            Text(viewModel.agentName)
                .font(.headline)
                .foregroundStyle(.white)
            if !viewModel.agentEmail.isEmpty {
                Text(viewModel.agentEmail)
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.6))
            }
            Text("Travel Agent")
                .font(.caption2)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color("AccentOrange").opacity(0.85))
                .clipShape(Capsule())
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 20)
    }

    private func menuRow(_ item: SideMenuItem) -> some View {
        Button {
            viewModel.closeSideMenu()
            // TODO: navigate to each section once screens are built
        } label: {
            HStack(spacing: 14) {
                Image(systemName: item.systemImage)
                    .frame(width: 22)
                    .foregroundStyle(.white.opacity(0.85))
                Text(item.title)
                    .font(.subheadline)
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    private var logoutButton: some View {
        Button {
            viewModel.logout()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .frame(width: 22)
                    .foregroundStyle(Color("AccentOrange"))
                Text("Sign Out")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("AccentOrange"))
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Menu Items

enum SideMenuItem: String, CaseIterable, Identifiable {
    case myBookings, deposits, statement, airlines, markup
    case notifications, myProfile, writeQuery, referFriend, terms

    var id: String { rawValue }

    var title: String {
        switch self {
        case .myBookings:    return String(localized: "My Bookings")
        case .deposits:      return String(localized: "Deposits")
        case .statement:     return String(localized: "Statement")
        case .airlines:      return String(localized: "Airlines")
        case .markup:        return String(localized: "Markup")
        case .notifications: return String(localized: "Notifications")
        case .myProfile:     return String(localized: "My Profile")
        case .writeQuery:    return String(localized: "Write a Query")
        case .referFriend:   return String(localized: "Refer a Friend")
        case .terms:         return String(localized: "Terms & Condition")
        }
    }

    var systemImage: String {
        switch self {
        case .myBookings:    return "list.bullet.rectangle"
        case .deposits:      return "banknote"
        case .statement:     return "doc.plaintext"
        case .airlines:      return "airplane"
        case .markup:        return "percent"
        case .notifications: return "bell"
        case .myProfile:     return "person.circle"
        case .writeQuery:    return "questionmark.circle"
        case .referFriend:   return "person.2"
        case .terms:         return "doc.text"
        }
    }
}
