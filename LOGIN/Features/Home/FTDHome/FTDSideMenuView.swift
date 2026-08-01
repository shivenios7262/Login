import SwiftUI

// MARK: - Context

struct SideMenuContext {
    let agentName: String
    let agentEmail: String
    let onMyBookings: () -> Void
    let onUploadMoney: () -> Void
    let onMyRefund: () -> Void
    let onStatement: () -> Void
    let onMarkups: () -> Void
    let onProfile: () -> Void
    let onClose: () -> Void
    let onLogout: () -> Void
}

// MARK: - Private data types

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
    let context: SideMenuContext

    private static let menuSections: [SideMenuSection] = [
        SideMenuSection(title: "MY WALLET", items: [
            SideMenuRowItem(icon: "chart.bar.fill",           title: "My Markup"),
            SideMenuRowItem(icon: "doc.text.fill",            title: "Statements"),
        ]),
        SideMenuSection(title: "MY BOOKINGS", items: [
            SideMenuRowItem(icon: "suitcase.fill",            title: "My Bookings"),
            SideMenuRowItem(icon: "person.2.fill",            title: "Group Fare"),
            SideMenuRowItem(icon: "heart.fill",               title: "Wishlist"),
            SideMenuRowItem(icon: "calendar",                 title: "Calendar"),
        ]),
        SideMenuSection(title: "MY ACCOUNT", items: [
            SideMenuRowItem(icon: "person.fill",              title: "My Profile"),
            SideMenuRowItem(icon: "bell.fill",                title: "Notification", badge: "12"),
            SideMenuRowItem(icon: "star.fill",                title: "My reviews"),
            SideMenuRowItem(icon: "gift.fill",                title: "Refer & Earn"),
        ]),
        SideMenuSection(title: "SUPPORT & SETTINGS", items: [
            SideMenuRowItem(icon: "qrcode",                   title: "App Code"),
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
            quickActionsRow
            Divider()
                .overlay(Color.ftdBorder)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(Self.menuSections, id: \.title) { section in
                        sectionView(section)
                    }
                }
                .padding(.bottom, DesignTokens.Spacing.sm)
            }
            logoutFooter
        }
        .frame(maxHeight: .infinity)
        .background(Color.ftdSideMenuBackground)
        .ignoresSafeArea(edges: .vertical)
    }

    // MARK: - Banner Header (profile overlaid at bottom)

    private var bannerHeader: some View {
        ZStack(alignment: .bottom) {
            Image("splashMiddleImg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .clipped()
            LinearGradient(
                colors: [.clear, .black.opacity(0.65)],
                startPoint: .center,
                endPoint: .bottom
            )
            Button { context.onProfile() } label: {
                HStack(spacing: DesignTokens.Spacing.md) {
                    avatarCircle
                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                        Text(context.agentName)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        if !context.agentEmail.isEmpty {
                            Text(context.agentEmail)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.system(size: DesignTokens.IconSize.xs, weight: .semibold))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.md)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(height: 160)
    }

    private var avatarCircle: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [Color.ftdAccentOrange, Color.ftdAccentTeal],
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
        let words   = context.agentName.split(separator: " ")
        let letters = words.prefix(2).compactMap { $0.first.map { String($0).uppercased() } }
        return letters.isEmpty ? "?" : letters.joined()
    }

    // MARK: - Quick Actions Row

    private var quickActionsRow: some View {
        HStack(spacing: 0) {
            quickActionItem(icon: "ticket.fill",                        label: "My\nBookings") { context.onMyBookings() }
            Rectangle()
                .fill(Color.ftdTextSecondary.opacity(0.35))
                .frame(width: 1, height: 36)
            quickActionItem(icon: "arrow.up.circle.fill",               label: "Upload\nMoney") { context.onUploadMoney() }
            Rectangle()
                .fill(Color.ftdTextSecondary.opacity(0.35))
                .frame(width: 1, height: 36)
            quickActionItem(icon: "arrow.counterclockwise.circle.fill", label: "My\nRefund") { context.onMyRefund() }
        }
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.ftdSideMenuBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .stroke(Color.ftdBorder, lineWidth: 1.5)
        )
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
    }

    private func quickActionItem(icon: String, label: String, action: @escaping () -> Void) -> some View {
        Button { action() } label: {
            VStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.system(size: DesignTokens.IconSize.lg))
                    .foregroundStyle(Color.ftdAccentOrange)
                Text(label)
                    .font(.ftdLabelXS)
                    .foregroundStyle(Color.ftdTextPrimary)
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
        // labelOffset = half the rendered label height so its midline sits on the border
        let labelOffset: CGFloat = 7

        return ZStack(alignment: .topLeading) {
            // Bordered box — same background as page so the whole view is one colour
            VStack(spacing: 0) {
                ForEach(section.items) { item in
                    menuRow(item)
                }
            }
            .background(Color.ftdSideMenuBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                    .stroke(Color.ftdBorder, lineWidth: 1.5)
            )
            .padding(.top, labelOffset)   // drop card so label midline lands on top border

            // Title punches through the top border line, centred on it
            Text(section.title)
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(Color.ftdTextSecondary)
                .tracking(0.8)
                .padding(.horizontal, 5)
                .background(Color.ftdSideMenuBackground)   // erases border behind text
                .padding(.leading, DesignTokens.Spacing.lg)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.top, DesignTokens.Spacing.xl)        // generous breathing space above each section
        .padding(.bottom, DesignTokens.Spacing.xs)     // subtle gap below each card
    }

    private func menuRow(_ item: SideMenuRowItem) -> some View {
        Button {
            switch item.title {
            case "Statements": context.onStatement()
            case "My Markup":  context.onMarkups()
            case "My Profile": context.onProfile()
            default:           context.onClose()
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: item.icon)
                    .font(.system(size: DesignTokens.IconSize.md))
                    .frame(width: 22)
                    .foregroundStyle(Color.ftdTextSecondary)
                Text(item.title)
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextPrimary)
                Spacer()
                if let badge = item.badge {
                    Text(badge)
                        .font(.ftdLabelXS)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 7)
                        .padding(.vertical, DesignTokens.Spacing.xxs)
                        .background(Color.ftdAccentOrange)
                        .clipShape(Capsule())
                }
                Image(systemName: "chevron.right")
                    .font(.system(size: DesignTokens.IconSize.xs))
                    .foregroundStyle(Color.ftdTextSecondary.opacity(0.45))
            }
            .padding(.horizontal, DesignTokens.Spacing.md)
            .padding(.vertical, 13)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Logout Footer

    private var logoutFooter: some View {
        VStack(spacing: DesignTokens.Spacing.inputVertical) {
            Divider().overlay(Color.ftdBorder)
            Button { context.onLogout() } label: {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: DesignTokens.IconSize.md, weight: .semibold))
                    Text("Logout")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 13)
                .background(Color.ftdSideMenuLogout)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, DesignTokens.Spacing.lg)

            Text("FTD Travel v1.0.0")
                .font(.system(size: 10))
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.55))
        }
        .padding(.top, DesignTokens.Spacing.sm - 2)
        .padding(.bottom, 30)
        .background(Color.ftdSideMenuBackground)
    }
}

// MARK: - Preview

private let previewContext = SideMenuContext(
    agentName: "Abhishek Jain",
    agentEmail: "abhishekjain.ftd@gmail.com",
    onMyBookings: {},
    onUploadMoney: {},
    onMyRefund: {},
    onStatement: {},
    onMarkups: {},
    onProfile: {},
    onClose: {},
    onLogout: {}
)
//
//#Preview("Light") {
//    FTDSideMenuView(context: previewContext)
//        .frame(width: 320)
//        .preferredColorScheme(.light)
//}
//
//#Preview("Dark") {
//    FTDSideMenuView(context: previewContext)
//        .frame(width: 320)
//        .preferredColorScheme(.dark)
//}
