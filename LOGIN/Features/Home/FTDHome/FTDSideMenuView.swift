import SwiftUI

// MARK: - Context

struct SideMenuContext {
    let agentName: String
    let agentEmail: String
    let agentPhone: String
    let agentPhotoURL: URL?
    let onMyBookings: () -> Void
    let onUploadMoney: () -> Void
    let onMyRefund: () -> Void
    let onAppCode: () -> Void
    let onStatement: () -> Void
    let onMarkups: () -> Void
    let onProfile: () -> Void
    let onAboutUs: () -> Void
    let onContactSupport: () -> Void
    let onPrivacyPolicy: () -> Void
    let onTermsCondition: () -> Void
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
            SideMenuRowItem(icon: "doc.text.fill",            title: "Statements"),
            SideMenuRowItem(icon: "chart.bar.fill",           title: "Markup"),
        ]),
        SideMenuSection(title: "MY BOOKINGS", items: [
            SideMenuRowItem(icon: "suitcase.fill",            title: "Bookings"),
            SideMenuRowItem(icon: "person.2.fill",            title: "Group Fare"),
            SideMenuRowItem(icon: "heart.fill",               title: "Wishlist"),
            SideMenuRowItem(icon: "calendar",                 title: "Calendar"),
        ]),
        SideMenuSection(title: "MY ACCOUNT", items: [
            SideMenuRowItem(icon: "person.fill",              title: "Profile"),
            SideMenuRowItem(icon: "bell.fill",                title: "Notification", badge: "12"),
            SideMenuRowItem(icon: "star.fill",                title: "Reviews"),
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

    // MARK: - Banner Header

    private var bannerHeader: some View {
        ZStack(alignment: .bottom) {
            Image("splashMiddleImg")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(maxWidth: .infinity)
                .frame(height: 160)
                .clipped()
            LinearGradient(
                colors: [.clear, .black.opacity(0.70)],
                startPoint: .center,
                endPoint: .bottom
            )
            Button { context.onProfile() } label: {
                HStack(spacing: DesignTokens.Spacing.md) {
                    avatarView
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.agentName)
                            .font(Font.custom("Poppins-SemiBold", size: 15))
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        if !context.agentEmail.isEmpty {
                            Text(context.agentEmail)
                                .font(Font.custom("Poppins-Regular", size: 12))
                                .foregroundStyle(.white.opacity(0.85))
                                .lineLimit(1)
                        }
                        if !context.agentPhone.isEmpty {
                            Text(context.agentPhone)
                                .font(Font.custom("Poppins-Regular", size: 12))
                                .foregroundStyle(.white.opacity(0.85))
                                .lineLimit(1)
                        }
                    }
                    Spacer()
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.md)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(height: 160)
    }

    private var avatarView: some View {
        Group {
            if let url = context.agentPhotoURL {
                FTDRemoteImage(url: url, contentMode: .fit) {
                    initialsBox
                }
                .frame(width: 64, height: 64)
                .background(Color.ftdCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                initialsBox
            }
        }
    }

    private var initialsBox: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [Color.ftdAccentOrange, Color.ftdAccentTeal],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 64, height: 64)
            Text(agentInitials)
                .font(Font.custom("Poppins-Bold", size: 18))
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
            quickActionItem(icon: "ticket.fill",                        label: "Bookings") { context.onMyBookings() }
            quickActionSeparator
            quickActionItem(icon: "arrow.up.circle.fill",               label: "Upload")   { context.onUploadMoney() }
            quickActionSeparator
            quickActionItem(icon: "arrow.counterclockwise.circle.fill", label: "Refund")   { context.onMyRefund() }
            quickActionSeparator
            quickActionItem(icon: "qrcode",                             label: "App Code") { context.onAppCode() }
        }
        .padding(.vertical, DesignTokens.Spacing.md)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .background(Color.ftdSideMenuBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .stroke(Color.ftdBorder, lineWidth: 1.5)
        )
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.vertical, DesignTokens.Spacing.sm)
    }

    private var quickActionSeparator: some View {
        Rectangle()
            .fill(Color.ftdTextSecondary.opacity(0.25))
            .frame(width: 1, height: 36)
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
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Menu Sections

    private func sectionView(_ section: SideMenuSection) -> some View {
        // labelOffset = half the rendered label height so its midline sits on the top border
        let labelOffset: CGFloat = 8

        return ZStack(alignment: .topLeading) {
            // Bordered card pushed down so the label midline lands on the top border
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
            .padding(.top, labelOffset)

            // Title centred on the top border line; background erases the border behind it
            Text(section.title)
                .font(.ftdSectionHeader)
                .foregroundStyle(Color.ftdTextSecondary)
                .tracking(0.8)
                .padding(.horizontal, 5)
                .background(Color.ftdSideMenuBackground)
                .padding(.leading, DesignTokens.Spacing.lg)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.top, DesignTokens.Spacing.xl)
        .padding(.bottom, DesignTokens.Spacing.xs)
    }

    private func menuRow(_ item: SideMenuRowItem) -> some View {
        Button {
            switch item.title {
            case "Statements":        context.onStatement()
            case "Markup":            context.onMarkups()
            case "Profile":           context.onProfile()
            case "About Us":          context.onAboutUs()
            case "Help & Support":    context.onContactSupport()
            case "Privacy Policy":    context.onPrivacyPolicy()
            case "Terms & Condition": context.onTermsCondition()
            case "App Code":          context.onAppCode()
            default:                  context.onClose()
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: item.icon)
                    .font(.system(size: DesignTokens.IconSize.md))
                    .frame(width: 22)
                    .foregroundStyle(Color.ftdAccentOrange)
                Text(item.title)
                    .font(Font.custom("Poppins-Regular", size: 14))
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
        VStack(spacing: DesignTokens.Spacing.sm) {
            Divider().overlay(Color.ftdBorder)
            Button { context.onLogout() } label: {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                        .font(.system(size: DesignTokens.IconSize.sm, weight: .semibold))
                    Text("Logout")
                        .font(Font.custom("Poppins-SemiBold", size: 14))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(Color.ftdSideMenuLogout)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, DesignTokens.Spacing.lg)

            Text("FTD Travel v1.0.0")
                .font(.ftdTabLabel)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.55))
        }
        .padding(.top, DesignTokens.Spacing.xs)
        .padding(.bottom, 24)
        .background(Color.ftdSideMenuBackground)
    }
}

// MARK: - Preview

private let previewContext = SideMenuContext(
    agentName: "Abhishek Jain",
    agentEmail: "abhishekjain.ftd@gmail.com",
    agentPhone: "9876543210",
    agentPhotoURL: nil,
    onMyBookings: {},
    onUploadMoney: {},
    onMyRefund: {},
    onAppCode: {},
    onStatement: {},
    onMarkups: {},
    onProfile: {},
    onAboutUs: {},
    onContactSupport: {},
    onPrivacyPolicy: {},
    onTermsCondition: {},
    onClose: {},
    onLogout: {}
)
