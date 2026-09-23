import SwiftUI

// MARK: - FTDHomeView

struct FTDHomeView: View {
    private let authManager: AuthManager
    @State private var viewModel:     FTDHomeViewModel
    @State private var bookingsVM:    BookingsViewModel
    @State private var profileVM:     ProfileViewModel
    @State private var statementVM:   StatementViewModel
    @State private var markupsVM:     MarkupsViewModel
    @State private var uploadMoneyVM: UploadMoneyViewModel
    @State private var contactVM:     ContactSupportViewModel
    @State private var privacyVM:     PrivacyPolicyViewModel
    @State private var termsVM:       TermsConditionViewModel
    @State private var appCodeVM:          AppCodeViewModel
    @State private var agentProfileEditVM: AgentProfileEditViewModel
    @State private var groupFareVM:        GroupFareViewModel
    @State private var calendarVM:         BookingCalendarViewModel
    @State private var refundVM:           RefundViewModel
    @State private var serviceSheetPresented = false
    @State private var selectedServiceName = ""
    @State private var selectedServiceIcon = ""
    @Environment(AppRouter.self) private var router
    @Environment(\.openURL) private var openURL

    init(authManager: AuthManager) {
        self.authManager      = authManager
        _viewModel            = State(initialValue: FTDHomeViewModel(authManager: authManager))
        _bookingsVM           = State(initialValue: BookingsViewModel(authManager: authManager))
        _profileVM            = State(initialValue: ProfileViewModel(authManager: authManager))
        _statementVM          = State(initialValue: StatementViewModel(authManager: authManager))
        _markupsVM            = State(initialValue: MarkupsViewModel(authManager: authManager))
        _uploadMoneyVM        = State(initialValue: UploadMoneyViewModel(authManager: authManager))
        _contactVM            = State(initialValue: ContactSupportViewModel(authManager: authManager))
        _privacyVM            = State(initialValue: PrivacyPolicyViewModel(authManager: authManager))
        _termsVM              = State(initialValue: TermsConditionViewModel(authManager: authManager))
        _appCodeVM            = State(initialValue: AppCodeViewModel(authManager: authManager))
        _agentProfileEditVM   = State(initialValue: AgentProfileEditViewModel(authManager: authManager))
        _groupFareVM          = State(initialValue: GroupFareViewModel(authManager: authManager))
        _calendarVM           = State(initialValue: BookingCalendarViewModel(authManager: authManager))
        _refundVM             = State(initialValue: RefundViewModel(authManager: authManager))
    }

    var body: some View {
        NavigationStack(path: Bindable(router).homePath) {
            ZStack(alignment: .leading) {
                tabLayout
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Dim overlay behind open side menu
                Color.black
                    .opacity(viewModel.isSideMenuOpen ? 0.45 : 0)
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: DesignTokens.Animation.standard), value: viewModel.isSideMenuOpen)
                    .allowsHitTesting(viewModel.isSideMenuOpen)
                    .onTapGesture { viewModel.closeSideMenu() }

                FTDSideMenuView(context: sideMenuContext)
                    .frame(width: 310)
                    .offset(x: viewModel.isSideMenuOpen ? 0 : -310)
                    .animation(.easeInOut(duration: DesignTokens.Animation.standard), value: viewModel.isSideMenuOpen)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: AppRouter.HomeDestination.self) { dest in
                switch dest {
                case .profile:
                    AgentProfileView(viewModel: profileVM)
                case .profileEdit:
                    AgentProfileEditView(viewModel: agentProfileEditVM)
                }
            }
        }
        .sheet(item: Bindable(router).homeSheet) { sheet in
            switch sheet {
            case .myBookings:  MyBookingsView(viewModel: bookingsVM)
            // TODO: StatementView is an Excel export view — replaced by RefundView for the My Refund flow.
            // case .statement: StatementView(viewModel: statementVM)
            case .markups:     MarkupSummaryView(viewModel: markupsVM)
            case .aboutUs:         NavigationStack { AboutView() }
            case .contactSupport:  NavigationStack { ContactSupportView(viewModel: contactVM) }
            case .privacyPolicy:   NavigationStack { PrivacyPolicyView(viewModel: privacyVM) }
            case .termsCondition:  NavigationStack { TermsConditionView(viewModel: termsVM) }
            case .appCode:         AppCodeView(viewModel: appCodeVM)
            }
        }
        .fullScreenCover(isPresented: Bindable(router).uploadMoneyPresented) {
            UploadMoneyView(viewModel: uploadMoneyVM)
        }
        .fullScreenCover(isPresented: Bindable(router).agencyStatementPresented) {
            AgencyStatementView(authManager: authManager)
        }
        .fullScreenCover(isPresented: Bindable(router).groupFarePresented) {
            GroupFareView(viewModel: groupFareVM)
        }
        .fullScreenCover(isPresented: Bindable(router).calendarPresented) {
            BookingCalendarView(viewModel: calendarVM)
        }
        .fullScreenCover(isPresented: Bindable(router).refundPresented) {
            RefundView(viewModel: refundVM)
        }
        .fullScreenCover(isPresented: Bindable(router).markupsPresented) {
            MarkupSummaryView(viewModel: markupsVM)
        }
        .sheet(isPresented: $serviceSheetPresented) {
            ServiceComingSoonView(icon: selectedServiceIcon, name: selectedServiceName)
        }
        .alert("Update Available", isPresented: Binding(
            get: { viewModel.showUpdateAlert },
            set: { viewModel.showUpdateAlert = $0 }
        )) {
            if let url = viewModel.appStoreURL {
                Button("Update Now") { openURL(url) }
            }
            Button("Later", role: .cancel) { }
        } message: {
            Text("A new version of FTD Travel is available on the App Store.")
        }
        .task {
            await viewModel.checkAndRefreshTokenIfNeeded()
            await viewModel.refreshBalance()
            await viewModel.checkForAppStoreUpdate()
        }
    }

    // MARK: - Side Menu Context

    private var sideMenuContext: SideMenuContext {
        SideMenuContext(
            agentName:     viewModel.agentName,
            agentEmail:    viewModel.agentEmail,
            agentPhone:    viewModel.mobileNo,
            agentPhotoURL: viewModel.agentLogoURL,
            onMyBookings:  { viewModel.closeSideMenu(); router.presentHome(.myBookings) },
            onUploadMoney: { viewModel.closeSideMenu(); router.presentUploadMoney() },
            onMyRefund:    { viewModel.closeSideMenu(); router.presentRefund() },
            onAppCode:     { viewModel.closeSideMenu(); router.presentHome(.appCode) },
            onStatement:   { viewModel.closeSideMenu(); router.presentAgencyStatement() },
            onMarkups:     { viewModel.closeSideMenu(); router.presentHome(.markups) },
            onGroupFare:   { viewModel.closeSideMenu(); router.presentGroupFare() },
            onCalendar:    { viewModel.closeSideMenu(); router.presentCalendar() },
            onProfile:     { viewModel.closeSideMenu(); router.navigateHome(.profileEdit) },
            onAboutUs:         { viewModel.closeSideMenu(); router.presentHome(.aboutUs) },
            onContactSupport:  { viewModel.closeSideMenu(); router.presentHome(.contactSupport) },
            onPrivacyPolicy:   { viewModel.closeSideMenu(); router.presentHome(.privacyPolicy) },
            onTermsCondition:  { viewModel.closeSideMenu(); router.presentHome(.termsCondition) },
            onClose:           { viewModel.closeSideMenu() },
            onLogout:      { viewModel.logout() }
        )
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
        case .myTrips:    placeholderScreen(title: "Upload",   icon: "bag.fill")
        case .wishlists:  placeholderScreen(title: "Markup",   icon: "heart.fill")
        case .creditCard: placeholderScreen(title: "App Code", icon: "creditcard.fill")
        }
    }

    // MARK: - Home Screen

    private var homeScreen: some View {
        VStack(spacing: 0) {
            topBar
            Spacer(minLength: 0)
            servicesGlassCard
                .padding(.horizontal, DesignTokens.Spacing.lg)
            Spacer(minLength: 0)
            //Text(DeviceInfo.modelIdentifier)
               // .font(.caption2)
                //.foregroundStyle(.white.opacity(0.6))
                //.padding(.bottom, DesignTokens.Spacing.sm)
//            ScrollView(showsIndicators: false) {
//                VStack(spacing: 0) {
//                    // TODO: Re-enable AI search bar once travel assistant feature is ready
//                    // aiSearchBar
//                    //     .padding(.horizontal, DesignTokens.Spacing.lg)
//                    //     .padding(.vertical, DesignTokens.Spacing.md)
//
//                    // TODO: Re-enable agent profile card once profile data flow is finalised
//                    // agentProfileCard
//                    //     .padding(.horizontal, DesignTokens.Spacing.lg)
//                    //     .padding(.top, DesignTokens.Spacing.lg)
//                    //     .padding(.bottom, DesignTokens.Spacing.md)
//                    // TODO: Re-enable agent profile card once profile data flow is finalised
//                    // categoryPanel
//                    // TODO: Re-enable agent profile card once profile data flow is finalised
//                    //offersSection
//                    //     .padding(.top, DesignTokens.Spacing.xl)
//
//                    Spacer(minLength: DesignTokens.Spacing.xxl)
//                }
//            }
//            .background(Color.clear)
        }
        .background {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.04, green: 0.12, blue: 0.30),
                        Color(red: 0.01, green: 0.06, blue: 0.18)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                if let image = viewModel.wallpaperImage {
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .transition(.opacity)
                }
            }
            .animation(.easeIn(duration: 0.45), value: viewModel.wallpaperImage != nil)
            .ignoresSafeArea()
        }
    }

    // MARK: - Top Bar

    private var userAvatar: some View {
        Button { router.navigateHome(.profileEdit) } label: {
            HStack(spacing: DesignTokens.Spacing.sm) {
//                // Logo / initials tile
//                ZStack {
//                    LinearGradient(
//                        colors: [Color.ftdAccentOrange, Color.ftdAccentTeal],
//                        startPoint: .topLeading,
//                        endPoint: .bottomTrailing
//                    )
//                    if let url = viewModel.agentLogoURL {
//                        AsyncImage(url: url) { phase in
//                            if case .success(let image) = phase {
//                                image
//                                    .resizable()
//                                    .aspectRatio(contentMode: .fit)
//                                    .padding(4)
//                            } else {
//                                initialsLabel
//                            }
//                        }
//                    } else {
//                        initialsLabel
//                    }
//                }
//                .frame(width: 36, height: 36)
//                .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
//                .overlay(
//                    RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
//                        .stroke(Color.ftdAccentOrange.opacity(0.4), lineWidth: 1)
//                )

                // Agency name
                if !viewModel.agencyName.isEmpty {
                    Text(viewModel.agencyName)
                        .font(.ftdLabelSM)
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, DesignTokens.Spacing.sm)
                        .padding(.vertical, 5)
                        .background(
                            LinearGradient(
                                colors: [Color.ftdAccentOrange, Color.ftdAccentTeal],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var initialsLabel: some View {
        Text(viewModel.agentName.prefix(2).uppercased())
            .font(.system(size: 13, weight: .bold))
            .foregroundStyle(.white)
    }

    private var topBar: some View {
        HStack(spacing: DesignTokens.Spacing.inputVertical) {
            Button { viewModel.toggleSideMenu() } label: {
                Image(systemName: "line.3.horizontal")
                    .font(.title2)
                    .foregroundStyle(Color.ftdTextPrimary)
            }

            userAvatar
                .frame(maxWidth: .infinity, alignment: .leading)

//            Button { /* TODO: open agent wallet */ } label: {
//                Text(viewModel.creditBalanceLabel)
//                    .font(.caption).fontWeight(.semibold)
//                    .padding(.horizontal, DesignTokens.Spacing.inputVertical)
//                    .padding(.vertical, 5)
//                    .background(Color.ftdAccentOrange.opacity(0.12))
//                    .foregroundStyle(Color.ftdAccentOrange)
//                    .clipShape(Capsule())
//                    .overlay(Capsule().stroke(Color.ftdAccentOrange.opacity(0.4), lineWidth: 1))
//            }

//            Button { /* TODO: open B2B portal */ } label: {
//                Text("B2B")
//                    .font(.caption).fontWeight(.bold)
//                    .padding(.horizontal, DesignTokens.Spacing.inputVertical)
//                    .padding(.vertical, 5)
//                    .background(Color.ftdAccentTeal.opacity(0.12))
//                    .foregroundStyle(Color.ftdAccentTeal)
//                    .clipShape(Capsule())
//                    .overlay(Capsule().stroke(Color.ftdAccentTeal.opacity(0.4), lineWidth: 1))
//            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
    }

    // MARK: - AI Search Bar

    private var aiSearchBar: some View {
        Button { /* TODO: open AI travel assistant */ } label: {
            HStack(spacing: DesignTokens.Spacing.inputVertical) {
                Image(systemName: "sparkles")
                    .foregroundStyle(Color.ftdAccentOrange)
                    .font(.subheadline)

                Text("Ask FTD about travel options...")
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                HStack(spacing: DesignTokens.Spacing.xs) {
                    Image(systemName: "waveform").font(.caption)
                    Text("Speak").font(.caption).fontWeight(.semibold)
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.sm - 2)
                .background(Color.ftdAccentOrange.opacity(0.1))
                .foregroundStyle(Color.ftdAccentOrange)
                .clipShape(Capsule())
                .overlay(Capsule().stroke(Color.ftdAccentOrange.opacity(0.3), lineWidth: 1))
            }
            .padding(.horizontal, 14)
            .padding(.vertical, DesignTokens.Spacing.inputVertical)
            .background(Color.ftdCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.search))
            .overlay(RoundedRectangle(cornerRadius: DesignTokens.Radius.search).stroke(Color.ftdBorder, lineWidth: 1))
            .shadow(color: .black.opacity(0.05), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Category Panel

    private var categoryPanel: some View {
        VStack(spacing: 0) {
            primaryCategoryRow
            Divider().padding(.horizontal, DesignTokens.Spacing.md)
            secondaryCategoryGrid
        }
        .background(Color.ftdCardBackground)
        .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
    }

    private var primaryCategoryRow: some View {
        HStack(spacing: 0) {
            ForEach(ServiceCategory.primaryCategories) { category in
                primaryTile(category)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
    }

    private func primaryTile(_ category: ServiceCategory) -> some View {
        Button { /* TODO: navigate to category */ } label: {
            VStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: category.icon)
                    .font(.ftdPrimaryIcon)
                    .foregroundStyle(Color.ftdAccentOrange)
                    .frame(height: 42)
                Text(category.label)
                    .font(.caption).fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.ftdTextPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.lg)
        }
        .buttonStyle(.plain)
    }

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

            Image(systemName: "chevron.up")
                .font(.caption2)
                .foregroundStyle(Color.ftdTextSecondary)
                .padding(.vertical, DesignTokens.Spacing.sm)
        }
    }

    private func secondaryTile(_ category: ServiceCategory) -> some View {
        Button { /* TODO: navigate to category */ } label: {
            ZStack(alignment: .topTrailing) {
                VStack(spacing: DesignTokens.Spacing.sm - 2) {
                    Image(systemName: category.icon)
                        .font(.ftdSecondaryIcon)
                        .foregroundStyle(Color.ftdAccentOrange)
                        .frame(height: 30)
                    Text(category.label)
                        .font(.ftdLabelXS)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(Color.ftdTextPrimary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignTokens.Spacing.md)
                .padding(.horizontal, DesignTokens.Spacing.xs)

                if let badge = category.badge {
                    Text(badge)
                        .font(.ftdBadgeXS)
                        .padding(.horizontal, DesignTokens.Spacing.xs)
                        .padding(.vertical, DesignTokens.Spacing.xxs)
                        .background(Color.ftdDestructiveRed)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                        .offset(x: -DesignTokens.Spacing.xs, y: DesignTokens.Spacing.xs)
                }
            }
            .overlay(Rectangle().stroke(Color.ftdBorder.opacity(0.4), lineWidth: 0.5))
        }
        .buttonStyle(.plain)
    }

    // MARK: - Services Glass Card

    private var servicesGlassCard: some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            VStack(spacing: DesignTokens.Spacing.xs) {
                Text("Welcome to\nFTD Travel")
                    .font(.title).fontWeight(.bold)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                Text("A B2B Travel Portal Built Exclusively for Our Travel Partners")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }

            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: DesignTokens.Spacing.lg
            ) {
                ForEach(homeServiceItems, id: \.label) { item in
                    serviceGlassTile(icon: item.icon, label: item.label)
                }
            }
        }
        .padding(DesignTokens.Spacing.xl)
        .background(Color.white.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .overlay {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.12), radius: 12, y: 4)
    }

    private func serviceGlassTile(icon: String, label: String) -> some View {
        Button {
            selectedServiceName = label
            selectedServiceIcon = icon
            serviceSheetPresented = true
        } label: {
            VStack(spacing: DesignTokens.Spacing.sm) {
                Image(systemName: icon)
                    .font(.system(size: 30, weight: .light))
                    .foregroundStyle(.white)
                Text(label)
                    .font(.subheadline).fontWeight(.medium)
                    .foregroundStyle(.white)
            }
            .padding(DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                    .stroke(.white.opacity(0.55), lineWidth: 1.5)
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Agent Profile Card

    private var agentProfileCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            profileLogoBanner
            profileInfoGrid
        }
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .shadow(color: .black.opacity(0.07), radius: 8, y: 3)
    }

    // Logo image fills the banner; name / agency overlaid at the bottom.
    private var profileLogoBanner: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [Color.ftdAccentOrange.opacity(0.85), Color.ftdAccentTeal.opacity(0.75)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            FTDRemoteImage(url: viewModel.agentLogoURL, contentMode: .fill) {
                Color.clear
            }
            .allowsHitTesting(false)

            // Scrim so the text stays readable over any logo
            LinearGradient(
                colors: [.black.opacity(0.05), .black.opacity(0.60)],
                startPoint: .top,
                endPoint: .bottom
            )

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(viewModel.agentName)
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundStyle(.white)
                if !viewModel.agencyName.isEmpty {
                    Text(viewModel.agencyName)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }
            }
            .padding(DesignTokens.Spacing.md)
        }
        .frame(height: 120)
    }

    private var profileInfoGrid: some View {
        let fields: [(String, String)] = [
            (String(localized: "Agent No"),        viewModel.agentNo),
            (String(localized: "Email"),           viewModel.agentEmail),
            (String(localized: "Mobile"),          viewModel.mobileNo),
            (String(localized: "Booking Balance"), viewModel.bookingBalanceLabel),
            (String(localized: "Credit Balance"),  viewModel.creditBalanceDisplayLabel),
            (String(localized: "Registered"),      viewModel.registerDate),
            (String(localized: "Last Login"),      viewModel.lastLogin),
            (String(localized: "Last Booking"),    viewModel.lastBooking),
        ].filter { !$0.1.isEmpty }

        return LazyVGrid(
            columns: [GridItem(.flexible()), GridItem(.flexible())],
            alignment: .leading,
            spacing: 0
        ) {
            ForEach(fields, id: \.0) { label, value in
                profileInfoCell(label: label, value: value)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xs)
        .padding(.horizontal, DesignTokens.Spacing.xs)
    }

    private func profileInfoCell(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.ftdTextSecondary)
                .textCase(.uppercase)
                .tracking(0.4)
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(Color.ftdTextPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, DesignTokens.Spacing.sm)
        .padding(.vertical, DesignTokens.Spacing.sm)
    }

    // MARK: - Offers Section

    private var offersSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            offersHeader
                .padding(.horizontal, DesignTokens.Spacing.lg)
            offerFilterTabs
            offerCards
        }
    }

    private var offersHeader: some View {
        HStack {
            Text("Offers")
                .font(.headline).fontWeight(.bold)
                .foregroundStyle(Color.ftdTextPrimary)
            Spacer()
            Button { /* TODO: navigate to all offers */ } label: {
                HStack(spacing: DesignTokens.Spacing.xxs) {
                    Text("View All")
                        .font(.subheadline)
                        .foregroundStyle(Color.ftdAccentOrange)
                    Image(systemName: "chevron.right.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.ftdAccentOrange)
                }
            }
        }
    }

    private var offerFilterTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(OfferFilter.allCases) { filter in
                    offerFilterChip(filter)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
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
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.vertical, DesignTokens.Spacing.sm - 2)
                .background(isSelected ? Color.ftdAccentOrange : Color.ftdCardBackground)
                .foregroundStyle(isSelected ? Color.white : Color.ftdTextSecondary)
                .clipShape(Capsule())
                .overlay {
                    if !isSelected {
                        Capsule().stroke(Color.ftdBorder, lineWidth: 1)
                    }
                }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: viewModel.selectedOfferFilter)
    }

    private var offerCards: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignTokens.Spacing.md) {
                ForEach(offerConfigs.indices, id: \.self) { i in
                    offerCard(
                        headline: offerConfigs[i].label,
                        tag: offerConfigs[i].tag,
                        colors: offerConfigs[i].colors
                    )
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.xs)
        }
    }

    private func offerCard(headline: String, tag: String, colors: [Color]) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 200, height: 120)
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm - 2) {
                Text(tag)
                    .font(.ftdBadgeSM)
                    .padding(.horizontal, DesignTokens.Spacing.sm - 2)
                    .padding(.vertical, DesignTokens.Spacing.xxs)
                    .background(.white.opacity(0.9))
                    .foregroundStyle(Color.ftdAccentOrange)
                    .clipShape(Capsule())
                Text(headline)
                    .font(.subheadline).fontWeight(.bold)
                    .foregroundStyle(.white)
                    .lineLimit(2)
            }
            .padding(DesignTokens.Spacing.md)
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .shadow(color: .black.opacity(0.12), radius: 8, y: 4)
    }

    // MARK: - Placeholder Screen

    private func placeholderScreen(title: String, icon: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            Spacer()
            Image(systemName: icon)
                .font(.ftdHeroIcon)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.4))
            Text(title)
                .font(.title2).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextSecondary)
            Text("Coming soon")
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary.opacity(0.6))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ftdInputBackground)
    }

    // MARK: - Bottom Tab Bar

    private var bottomTabBar: some View {
        HStack(spacing: 0) {
            ForEach(FTDHomeTab.allCases) { tab in
                tabBarItem(tab)
            }
        }
        .background(Color.ftdCardBackground)
        .overlay(alignment: .top) { Divider() }
        .shadow(color: .black.opacity(0.06), radius: 6, y: -2)
    }

    private func tabBarItem(_ tab: FTDHomeTab) -> some View {
        let isActive = viewModel.selectedTab == tab
        return Button {
            switch tab {
            case .home:
                viewModel.selectedTab = .home
            case .myTrips:
                router.presentUploadMoney()
            case .wishlists:
                router.presentMarkups()
            case .creditCard:
                router.presentHome(.appCode)
            }
        } label: {
            VStack(spacing: DesignTokens.Spacing.xs) {
                Group {
                    if tab.isSystemIcon {
                        Image(systemName: isActive ? tab.selectedIcon : tab.icon)
                    } else {
                        Image(isActive ? tab.selectedIcon : tab.icon)
                    }
                }
                .font(.system(size: DesignTokens.IconSize.lg))
                .foregroundStyle(isActive ? Color.ftdAccentOrange : Color.ftdTextSecondary)
                Text(tab.title)
                    .font(isActive ? .ftdTabLabelBold : .ftdTabLabel)
                    .foregroundStyle(isActive ? Color.ftdAccentOrange : Color.ftdTextSecondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignTokens.Spacing.inputVertical)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: viewModel.selectedTab)
    }
}

// MARK: - Offer card data (ViewModel-level constant)

private extension FTDHomeView {
    var homeServiceItems: [(icon: String, label: String)] {[
        ("airplane",              "Flight"),
        ("building.2",           "Hotel"),
        ("bus",                  "Bus"),
        ("car",                  "Cab"),
        ("cross.case",           "Trip Care"),
        ("doc.badge.plus",       "Visa"),
        ("simcard",              "eSim"),
        ("figure.hiking",        "Activities"),
    ]}

    var offerConfigs: [(label: String, tag: String, colors: [Color])] {[
        ("Break Free\nTravel Sale", "FLIGHTS",  [Color.ftdAccentOrange.opacity(0.8), .red.opacity(0.5)]),
        ("Summer\nEscape Deals",   "HOTELS",   [.blue.opacity(0.6),                 .purple.opacity(0.5)]),
        ("Holiday\nPackages",      "HOLIDAYS", [.green.opacity(0.55),               .teal.opacity(0.5)]),
        ("Rail\nSaver Pass",       "RAILS",    [Color.ftdAccentTeal.opacity(0.7),   .blue.opacity(0.4)]),
    ]}
}

// MARK: - Service Coming Soon Sheet

private struct ServiceComingSoonView: View {
    let icon: String
    let name: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button { dismiss() } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(Color.ftdTextSecondary)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.lg)

            Spacer()

            VStack(spacing: DesignTokens.Spacing.lg) {
                ZStack {
                    Circle()
                        .fill(Color.ftdAccentOrange.opacity(0.1))
                        .frame(width: 100, height: 100)
                    Image(systemName: icon)
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(Color.ftdAccentOrange)
                }

                VStack(spacing: DesignTokens.Spacing.sm) {
                    Text(name)
                        .font(.title2).fontWeight(.bold)
                        .foregroundStyle(Color.ftdTextPrimary)

                    Text("Coming Soon")
                        .font(.headline).fontWeight(.semibold)
                        .foregroundStyle(Color.ftdAccentOrange)
                }

                Text("Stay tuned for updates!")
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.Spacing.xl)

            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.ftdInputBackground)
    }
}
