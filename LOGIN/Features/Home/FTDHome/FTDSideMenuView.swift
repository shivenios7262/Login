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
    let onGroupFare: () -> Void
    let onCalendar: () -> Void
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
    let action: () -> Void
}

// MARK: - FTDSideMenuView

struct FTDSideMenuView: View {
    let context: SideMenuContext

    private var menuSections: [SideMenuSection] {
        [
            SideMenuSection(title: "MY WALLET", items: [
                SideMenuRowItem(icon: "statments",            title: "Statements",      action: context.onStatement),
                SideMenuRowItem(icon: "markup",           title: "Markup",          action: context.onMarkups),
            ]),
            SideMenuSection(title: "MY BOOKINGS", items: [
                SideMenuRowItem(icon: "ticket",            title: "Bookings",        action: context.onMyBookings),
                SideMenuRowItem(icon: "group",            title: "Group Fare",      action: context.onGroupFare),
               // SideMenuRowItem(icon: "wishlist",               title: "Wishlist",        action: context.onClose),
               // SideMenuRowItem(icon: "calender",                 title: "Calendar",        action: context.onCalendar),
            ]),
            SideMenuSection(title: "MY ACCOUNT", items: [
                SideMenuRowItem(icon: "profile",              title: "Profile",         action: context.onProfile),
                //SideMenuRowItem(icon: "notification",                title: "Notification",    badge: "12", action: context.onClose),
               // SideMenuRowItem(icon: "review",                title: "Reviews",         action: context.onClose),
               // SideMenuRowItem(icon: "refer",                title: "Refer & Earn",    action: context.onClose),
            ]),
            SideMenuSection(title: "SUPPORT & SETTINGS", items: [
                SideMenuRowItem(icon: "appcode",                   title: "App Code",        action: context.onAppCode),
                SideMenuRowItem(icon: "help", title: "Help & Support",  action: context.onContactSupport),
              //  SideMenuRowItem(icon: "setting",           title: "Settings",        action: context.onClose),
            ]),
            SideMenuSection(title: "ABOUT", items: [
                SideMenuRowItem(icon: "info",         title: "About Us",        action: context.onAboutUs),
                SideMenuRowItem(icon: "doc",         title: "Privacy Policy",  action: context.onPrivacyPolicy),
                SideMenuRowItem(icon: "doc",       title: "Terms & Condition", action: context.onTermsCondition),
            ]),
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            bannerHeader
            Spacer(minLength: 8)
            quickActionsRow
            Divider()
                .overlay(Color.ftdBorder)
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    ForEach(menuSections, id: \.title) { section in
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
            Image("menuHeader")
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .frame(height: 150, alignment: .bottom)
                .clipped()
            LinearGradient(
                colors: [.clear, .black.opacity(0.70)],
                startPoint: .center,
                endPoint: .bottom
            )
            Button { context.onProfile() } label: {
                HStack(spacing: DesignTokens.Spacing.md) {
                    avatarView
                    VStack(alignment: .leading, spacing: 0) {
                        Spacer(minLength: 0)
                        Text(context.agentName)
                            .font(.ftdMenuName)
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        //Spacer(minLength: )
                        VStack(alignment: .leading, spacing: 1) {
                            if !context.agentEmail.isEmpty {
                                Text(context.agentEmail)
                                    .font(.ftdPlaceholder)
                                    .foregroundStyle(.white.opacity(0.85))
                                    .lineLimit(1)
                            }
                            if !context.agentPhone.isEmpty {
                                Text(context.agentPhone)
                                    .font(.ftdPlaceholder)
                                    .foregroundStyle(.white.opacity(0.85))
                                    .lineLimit(1)
                            }
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(height: 64)
                    Spacer()
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.md)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
        }
        .frame(height: 150)
    }

    private var avatarView: some View {
        let url = context.agentPhotoURL ?? FTDImageURL.agentLogoDefault
        return FTDRemoteImage(url: url, contentMode: .fit) {
            initialsBox
        }
        .frame(width: 64, height: 64)
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
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
                .font(.ftdAvatarLabel)
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
            quickActionItem(icon: "ticket",                        label: "sidemenu.action.bookings") { context.onMyBookings() }
            quickActionSeparator
            quickActionItem(icon: "wallet",               label: "sidemenu.action.upload")   { context.onUploadMoney() }
            quickActionSeparator
            quickActionItem(icon: "refund", label: "sidemenu.action.refund")   { context.onMyRefund() }
            quickActionSeparator
            quickActionItem(icon: "appcode",                             label: "sidemenu.action.appcode") { context.onAppCode() }
        }
        
        .padding(.vertical, DesignTokens.Spacing.lg)
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

    private func quickActionItem(icon: String, label: LocalizedStringKey, action: @escaping () -> Void) -> some View {
        Button { action() } label: {
            VStack(spacing: 5) {
                Image(icon)
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
            Text(LocalizedStringKey(section.title))
                .font(.ftdLabelXS)
                .foregroundStyle(Color.ftdTextShade)
                .tracking(0.8)
                .padding(.horizontal, 5)
                .background(Color.ftdSideMenuBackground)
                .padding(.leading, DesignTokens.Spacing.lg)
        }
        .padding(.horizontal, DesignTokens.Spacing.md)
        .padding(.top, DesignTokens.Spacing.sm)
        .padding(.bottom, DesignTokens.Spacing.xs)
    }

    private func menuRow(_ item: SideMenuRowItem) -> some View {
        Button {
            item.action()
        } label: {
            HStack(spacing: 14) {
                Image(item.icon)
                    .font(.system(size: DesignTokens.IconSize.md))
                    .frame(width: 22)
                    .foregroundStyle(Color.ftdAccentOrange)
                Text(LocalizedStringKey(item.title))
                    .font(.ftdLabelMD)
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
                Image("chevron.right")
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
                    Image("logout")
                        .font(.system(size: DesignTokens.IconSize.sm, weight: .semibold))
                    Text("Logout")
                        .font(.ftdLabelXS)
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 9)
                .background(Color.ftdSideMenuLogout)
                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, DesignTokens.Spacing.lg)

            Text("FTD Travel v\(Bundle.main.infoDictionary?["APP_VERSION"] as? String ?? "–")")
                .font(.ftdLabelXS)
                .foregroundStyle(Color.ftdTextTertiary/*.opacity(0.55)*/)
        }
        .padding(.top, DesignTokens.Spacing.xs)
        .padding(.bottom, 24)
        .background(Color.ftdSideMenuBackground)
    }
}

// MARK: - Preview
//
//private let previewContext = SideMenuContext(
//    agentName: "Abhishek Jain",
//    agentEmail: "abhishekjain.ftd@gmail.com",
//    agentPhone: "9876543210",
//    agentPhotoURL: nil,
//    onMyBookings: {},
//    onUploadMoney: {},
//    onMyRefund: {},
//    onAppCode: {},
//    onStatement: {},
//    onMarkups: {},
//    onProfile: {},
//    onAboutUs: {},
//    onContactSupport: {},
//    onPrivacyPolicy: {},
//    onTermsCondition: {},
//    onClose: {},
//    onLogout: {}
//)
