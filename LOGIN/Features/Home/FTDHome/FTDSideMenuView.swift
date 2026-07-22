import SwiftUI

// MARK: - Data Types

private struct SideMenuSection {
    let title: String
    let items: [SideMenuRowItem]
}

private struct SideMenuRowItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    var badge: String? = nil
}

// MARK: - FTDSideMenuView

struct FTDSideMenuView: View {
    var viewModel: FTDHomeViewModel

    private static let menuSections: [SideMenuSection] = [
        SideMenuSection(title: "WALLET", items: [
            SideMenuRowItem(icon: "chart.bar.fill",           title: "My Markup"),
            SideMenuRowItem(icon: "doc.text.fill",            title: "Statements"),
        ]),
        SideMenuSection(title: "BOOKINGS", items: [
            SideMenuRowItem(icon: "person.2.fill",            title: "Group Fare"),
            SideMenuRowItem(icon: "heart.fill",               title: "Wishlist"),
            SideMenuRowItem(icon: "calendar",                 title: "Calendar"),
        ]),
        SideMenuSection(title: "ACCOUNT", items: [
            SideMenuRowItem(icon: "person.fill",              title: "My Profile"),
            SideMenuRowItem(icon: "bell.fill",                title: "Notification", badge: "42"),
            SideMenuRowItem(icon: "star.fill",                title: "My reviews"),
            SideMenuRowItem(icon: "gift.fill",                title: "Refer & Earn"),
        ]),
        SideMenuSection(title: "SUPPORT & SETTINGS", items: [
            SideMenuRowItem(icon: "questionmark.circle.fill", title: "Help & Support"),
            SideMenuRowItem(icon: "gearshape.fill",           title: "Settings"),
        ]),
        SideMenuSection(title: "ABOUT", items: [
            SideMenuRowItem(icon: "info.circle.fill",         title: "About Us"),
            SideMenuRowItem(icon: "lock.shield.fill",         title: "Privacy Policy"),
            SideMenuRowItem(icon: "doc.plaintext.fill",       title: "Terms & Condition"),
        ]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            bannerHeader
            profileRow
            quickActionsRow
            Divider()
                .overlay(Color("BorderColor"))
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(Self.menuSections, id: \.title) { section in
                        sectionView(section)
                    }
                }
                .padding(.bottom, 8)
            }
            logoutFooter
        }
        .frame(maxHeight: .infinity)
        .background(Color("SideMenuBackground"))
        .ignoresSafeArea(edges: .vertical)
    }

    // MARK: - Banner Header

    private var bannerHeader: some View {
        ZStack(alignment: .bottom) {
            Image("splashMiddleImg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 140)
                .clipped()
            LinearGradient(
                colors: [.clear, .black.opacity(0.35)],
                startPoint: .center,
                endPoint: .bottom
            )
        }
        .frame(height: 140)
    }

    // MARK: - Profile Row

    private var profileRow: some View {
        HStack(spacing: 12) {
            avatarCircle
            VStack(alignment: .leading, spacing: 3) {
                Text(viewModel.agentName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(Color("TextPrimary"))
                    .lineLimit(1)
                if !viewModel.agentEmail.isEmpty {
                    Text(viewModel.agentEmail)
                        .font(.caption)
                        .foregroundStyle(Color("TextSecondary"))
                        .lineLimit(1)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color("TextSecondary").opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color("SideMenuBackground"))
    }

    private var avatarCircle: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color("AccentOrange"), Color("AccentTeal")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 46, height: 46)
            Text(agentInitials)
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
        }
    }

    private var agentInitials: String {
        let words = viewModel.agentName.split(separator: " ")
        let letters = words.prefix(2).compactMap { $0.first.map { String($0).uppercased() } }
        return letters.isEmpty ? "?" : letters.joined()
    }

    // MARK: - Quick Actions Row

    private var quickActionsRow: some View {
        HStack(spacing: 0) {
            quickActionItem(icon: "ticket.fill",                        label: "My\nBookings")
            Divider().frame(height: 36).overlay(Color("BorderColor"))
            quickActionItem(icon: "arrow.up.circle.fill",               label: "Upload\nMoney")
            Divider().frame(height: 36).overlay(Color("BorderColor"))
            quickActionItem(icon: "arrow.counterclockwise.circle.fill", label: "My\nRefund")
        }
        .padding(.vertical, 12)
        .background(Color("SideMenuBackground"))
    }

    private func quickActionItem(icon: String, label: String) -> some View {
        Button { viewModel.closeSideMenu() } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundStyle(Color("AccentOrange"))
                Text(label)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(Color("TextPrimary"))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Menu Sections

    private func sectionView(_ section: SideMenuSection) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(section.title)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color("TextSecondary"))
                .tracking(0.4)
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 2)
            ForEach(section.items) { item in
                menuRow(item)
                Divider()
                    .padding(.leading, 52)
                    .overlay(Color("BorderColor").opacity(0.4))
            }
        }
    }

    private func menuRow(_ item: SideMenuRowItem) -> some View {
        Button { viewModel.closeSideMenu() } label: {
            HStack(spacing: 14) {
                Image(systemName: item.icon)
                    .font(.system(size: 15))
                    .frame(width: 22)
                    .foregroundStyle(Color("TextSecondary"))
                Text(item.title)
                    .font(.subheadline)
                    .foregroundStyle(Color("TextPrimary"))
                Spacer()
                if let badge = item.badge {
                    Text(badge)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, 2)
                        .background(Color("AccentOrange"))
                        .clipShape(Capsule())
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: 11))
                    .foregroundStyle(Color("TextSecondary").opacity(0.45))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Logout Footer

    private var logoutFooter: some View {
        VStack(spacing: 10) {
            Divider().overlay(Color("BorderColor"))
            Button { viewModel.logout() } label: {
                HStack(spacing: 8) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: 15, weight: .semibold))
                    Text("Logout")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Color("SideMenuLogoutButtonBg"))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 16)

            Text("FTD Travel v1.0.0")
                .font(.system(size: 10))
                .foregroundStyle(Color("TextSecondary").opacity(0.55))
        }
        .padding(.top, 6)
        .padding(.bottom, 30)
        .background(Color("SideMenuBackground"))
    }
}
