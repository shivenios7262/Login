import SwiftUI

struct UploadMoneyView: View {
    @Bindable var viewModel: UploadMoneyViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showPopup = true
    @State private var showDatePicker = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ftdCardBackground.ignoresSafeArea()
                mainContent
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.ftdCardBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(String(localized: "Upload Money"))
                        .font(.ftdSectionHeaderMedium)
                        .foregroundStyle(Color.ftdTextPrimary)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image("back")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundStyle(Color.ftdTextPrimary)
                            .frame(width: 36, height: 36)
                            .background(Color.ftdCardBackground)
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "Back"))
                }

            }
            .alert(viewModel.alertItem?.title ?? "", isPresented: Binding(
                get: { viewModel.alertItem != nil },
                set: { if !$0 { viewModel.alertItem = nil } }
            )) {
                Button(String(localized: "OK")) { viewModel.alertItem = nil }
            } message: {
                Text(viewModel.alertItem?.message ?? "")
            }
        }
        .task {
            viewModel.reset()
            await viewModel.fetchData()
        }
        .overlay { if showPopup && !viewModel.specialMessage.isEmpty { uploadMoneyPopup } }
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.isNimbblPresented },
            set: { if !$0 { viewModel.handleNimbblDismiss() } }
        )) {
            nimbblCoverContent
        }
    }

    // MARK: - Popup

    private var uploadMoneyPopup: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()

            VStack(spacing: DesignTokens.Spacing.lg) {
                Text(viewModel.specialMessage)
                    .font(.ftdTitleLG)
                    .foregroundStyle(Color.ftdTextPrimary)
                    .multilineTextAlignment(.center)

                FTDPrimaryButton(title: String(localized: "Dismiss")) {
                    showPopup = false
                }
            }
            .padding(DesignTokens.Spacing.xxl)
            .background(Color.ftdCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.cardLg))
            .padding(.horizontal, DesignTokens.Spacing.xxl)
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.phase {
        case .loading:
            centerLoadingView
        case .failure(let message):
            failureView(message: message)
        case .success(let refNo, let message):
            successView(referenceNo: refNo, message: message)
        case .loaded, .submitting:
            paymentForm
        }
    }

    // MARK: - Payment Form

    private var paymentForm: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                walletBalanceCard
                paymentTypeSection
                if !viewModel.specialMessage.isEmpty {
                    InfoBanner(
                        icon: .system("info.circle.fill"),
                        title: "Notice",
                        message: LocalizedStringKey(viewModel.specialMessage)
                    )
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.top, DesignTokens.Spacing.lg)
                }
                if viewModel.paymentType == .offlineRequest {
                    offlineRequestSection
                } else {
                    instantTopUpSection
                        .padding(.top, DesignTokens.Spacing.lg)
                }
            }
            .padding(.bottom, DesignTokens.Spacing.xxxl)
        }
        .scrollDismissesKeyboard(.immediately)
        .overlay {
            if viewModel.isLoading {
                loadingOverlay
            }
        }
    }

    // MARK: - Wallet Balance Card

    private var walletBalanceCard: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                HStack(spacing: DesignTokens.Spacing.sm) {
                    iconTile {
                        Image("wallet")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 22, height: 22)
                    }

                    Text(String(localized: "Wallet Balance"))
                        .font(.ftdLabelMD)
                        .foregroundStyle(Color.ftdTextTertiary)
                }

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                    walletAmountView(viewModel.walletBalanceAmount)

                    Text(String(localized: "Available Balance"))
                        .font(.ftdLabelMD)
                        .foregroundStyle(Color.ftdTextTertiary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.lg)
            .frame(height: 131)
            .background(alignment: .center) {
                Image("walletHeader")
                    .resizable()
                    .scaledToFill()
                    .clipped()
                    .allowsHitTesting(false)
            }

            HStack(spacing: 0) {
                pendingStat(
                    icon: "doc",
                    label: String(localized: "Pending Request"),
                    value: "#\(viewModel.pendingCount)",
                    usesAssetIcon: true
                )

                Rectangle()
                    .fill(Color.ftdDivider)
                    .frame(width: 1)
                    .padding(.vertical, DesignTokens.Spacing.md)

                pendingStat(
                    icon: "rupee",
                    label: String(localized: "Pending Amount"),
                    value: viewModel.pendingAmount,
                    usesAssetIcon: true,
                    showRupeeImage: true
                )
            }
            .frame(height: 70)
            .background(Color.ftdCardBackground)
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(Color.ftdDivider)
                    .frame(height: 1)
            }
        }
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 0))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.ftdBorder.opacity(0.5))
                .frame(height: 1)
        }
    }

    private func pendingStat(icon: String, label: String, value: String, usesAssetIcon: Bool = false, showRupeeImage: Bool = false) -> some View {
        HStack(spacing: DesignTokens.Spacing.md) {
            Group {
                if usesAssetIcon {
                    Image(icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 16, height: 16)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
            }
            .foregroundStyle(Color.ftdAccentOrange)
            .frame(width: 32, height: 32)
            .background(Color.ftdAccentOrange.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(label)
                    .font(.ftdPlaceholder)
                    .foregroundStyle(Color.ftdTextTertiary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                if showRupeeImage {
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Image("rupee")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 12)
                            .foregroundStyle(Color.ftdTextSecondary)
                            .alignmentGuide(.firstTextBaseline) { d in d.height }
                        Text(value)
                            .font(.ftdButton)
                            .foregroundStyle(Color.ftdTextSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                } else {
                    Text(value)
                        .font(.ftdButton)
                        .foregroundStyle(Color.ftdTextSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func iconTile<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .foregroundStyle(Color.ftdAccentOrange)
            .frame(width: 34, height: 34)
            .background(Color.ftdCardBackground.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                    .stroke(Color.ftdAccentOrange.opacity(0.28), lineWidth: 1)
            }
    }

    @ViewBuilder
    private func walletAmountView(_ amount: String) -> some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.xxs) {
            Image("rupee")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(height: 18)
                .foregroundStyle(Color.ftdTextPrimary)
            Text(amount)
                .font(.ftdWalletAmount)
                .foregroundStyle(Color.ftdTextPrimary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
    }

//    private var walletTravelIllustration: some View {
//        HStack(alignment: .bottom, spacing: 10) {
//            skylineTower(width: 24, height: 110)
//            skylineDome
//            skylineTower(width: 18, height: 88)
//            skylineBuilding(width: 36, height: 58)
//            skylineBuilding(width: 44, height: 44)
//        }
//        .overlay(alignment: .topTrailing) {
//            UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 30)
//                .stroke(Color.ftdAccentOrange.opacity(0.42), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
//                .frame(width: 160, height: 32)
//                .rotationEffect(.degrees(14))
//                .offset(x: 36, y: -24)
//        }
//    }
//
//    private func skylineTower(width: CGFloat, height: CGFloat) -> some View {
//        VStack(spacing: 0) {
//            Rectangle()
//                .frame(width: width * 0.2, height: height * 0.12)
//            Triangle()
//                .frame(width: width * 0.55, height: height * 0.14)
//            RoundedRectangle(cornerRadius: width * 0.5)
//                .frame(width: width, height: height * 0.74)
//        }
//    }
//
//    private var skylineDome: some View {
//        VStack(spacing: 0) {
//            Circle()
//                .trim(from: 0, to: 0.5)
//                .frame(width: 72, height: 44)
//            Rectangle()
//                .frame(width: 86, height: 42)
//        }
//    }
//
//    private func skylineBuilding(width: CGFloat, height: CGFloat) -> some View {
//        VStack(spacing: 0) {
//            Triangle()
//                .frame(width: width * 0.8, height: height * 0.28)
//            Rectangle()
//                .frame(width: width, height: height * 0.72)
//        }
//    }

    // MARK: - Payment Type

    private var paymentTypeSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
            Text(String(localized: "Select Payment Type"))
                .font(.ftdMenuName)
                .foregroundStyle(Color.ftdTextPrimary)
                .padding(.top, DesignTokens.Spacing.md)

            HStack(spacing: DesignTokens.Spacing.xxl) {
                radioOption(
                    title: String(localized: "Offline Request"),
                    isSelected: viewModel.paymentType == .offlineRequest
                ) { viewModel.paymentType = .offlineRequest }
                radioOption(
                    title: String(localized: "Instant Top-up"),
                    isSelected: viewModel.paymentType == .instantTopUp
                ) { viewModel.paymentType = .instantTopUp }
                Spacer()
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.lg)
        .padding(.vertical, DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
    }

    private func radioOption(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.sm) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.ftdAccentOrange : Color.ftdBorder, lineWidth: 1.5)
                        .frame(width: 18, height: 18)
                    if isSelected {
                        Circle()
                            .fill(Color.ftdAccentOrange)
                            .frame(width: 10, height: 10)
                    }
                }
                Text(title)
                    .font(.ftdLabelMD)
                    .foregroundStyle(Color.ftdTextSecondary)
            }
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: isSelected)
    }

    // MARK: - Offline Request

    private var offlineRequestSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            offlineTabBar
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.xxs)
                .background(Color.ftdCardBackground)
            bankListSection
            formSection
                .padding(.horizontal, DesignTokens.Spacing.lg)
            if !viewModel.uploadTimingsText.isEmpty {
                Text(String(localized: "Upload timings: \(viewModel.uploadTimingsText)"))
                    .font(.ftdPlaceholder)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                    .padding(.bottom, DesignTokens.Spacing.lg)
            }
            FTDPrimaryButton(
                title: viewModel.selectedTab.submitTitle,
                action: { Task { await viewModel.submitOfflineRequest() } }
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)
        }
    }

    private var offlineTabBar: some View {
        HStack(spacing: 0) {
            ForEach(UploadMoneyViewModel.OfflineTab.allCases, id: \.self) { tab in
                Button { viewModel.selectTab(tab) } label: {
                    Text(tab.title)
                        .font(.ftdLabelMD)
                        .foregroundStyle(viewModel.selectedTab == tab ? Color.ftdAccentOrange : Color.ftdTextSecondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(viewModel.selectedTab == tab ? Color.ftdCardBackground : Color.clear)
                        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                                .stroke(viewModel.selectedTab == tab ? Color.ftdAccentOrange : Color.clear, lineWidth: 1)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(DesignTokens.Spacing.xxs)
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.button)
                .stroke(Color.ftdAccentOrangeAlpha, lineWidth: 1)
        )
        .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: viewModel.selectedTab)
    }

    // MARK: - Bank List

    private var bankListSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Select one of the option"))
                .font(.ftdMenuName)
                .foregroundStyle(Color.ftdTextPrimary)
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.top, DesignTokens.Spacing.xxs)

            VStack(spacing: DesignTokens.Spacing.md) {
                ForEach(viewModel.currentBanks) { bank in
                    bankCard(bank)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.sm)
        }
        
    }

    private func bankCard(_ bank: BankItem) -> some View {
        let isSelected = viewModel.selectedBankId == bank.bankId
        let isDisabled = viewModel.isDisabled(bank)
        let remark = viewModel.remark(for: bank)

        return Button { viewModel.selectBank(bank) } label: {
            VStack(alignment: .leading, spacing: 0) {
                // Logo row
                HStack(alignment: .center, spacing: 0) {
                    bankLogo(bank)
                    Spacer()
                    ZStack {
                        Circle()
                            .stroke(isSelected ? Color.ftdAccentOrange : Color.ftdBorder, lineWidth: 1.5)
                            .frame(width: 22, height: 22)
                        if isSelected {
                            Circle()
                                .fill(Color.ftdAccentOrange)
                                .frame(width: 16, height: 16)
                        }
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.top, DesignTokens.Spacing.sm)
                //.padding(.bottom, DesignTokens.Spacing.sm)

//                Rectangle()
//                    .fill(Color.ftdDivider)
//                    .frame(height: 1)

                // Detail grid
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.xxs) {
                        bankDetailColumn(label: String(localized: "Bank"), value: bank.bankName)
                        bankDetailColumn(label: String(localized: "Name"), value: bank.accountName)
                    }
                    HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                        bankDetailColumn(label: String(localized: "Current Account"), value: bank.accountNo)
                        bankDetailColumn(label: String(localized: "IFSC Code"), value: bank.ifscCode)
                    }
                }
                .padding(.horizontal, DesignTokens.Spacing.md)
                .padding(.vertical, DesignTokens.Spacing.md)

                if let remark, !remark.isEmpty {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.ftdLabelMD)
                            .foregroundStyle(Color.ftdRemarkRed)
                        Text(remark)
                            .font(.ftdLabelMD)
                            .foregroundStyle(Color.ftdRemarkRed)
                    }
                    .padding(.horizontal, DesignTokens.Spacing.md)
                    .padding(.bottom, DesignTokens.Spacing.sm)
                }
            }
            .background(isSelected ? Color.ftdAccentOrange.opacity(0.05) : Color.ftdSurfaceSubtle)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                    .stroke(
                        isSelected ? Color.ftdAccentOrangeAlpha : Color.ftdBorder,
                        lineWidth: isSelected ? 1 : 1
                    )
            )
            .opacity(isDisabled ? 1/*0.9*/ : 1)
        }
        .buttonStyle(.plain)
        .allowsHitTesting(!isDisabled)
        .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: isSelected)
    }

    private func bankLogo(_ bank: BankItem) -> some View {
        let url = viewModel.bankLogoURL(bank)
        let fallbackURL = FTDImageURL.bankLogoFallback
        return FTDRemoteImage(url: url, contentMode: .fit) {
            FTDRemoteImage(url: fallbackURL, contentMode: .fit) {
                Text(String(bank.bankName.prefix(1)))
                    .font(.ftdAvatarLabel)
                    .foregroundStyle(Color.ftdAccentOrange)
            }
        }
        .frame(width: 80, height: 20)
        .clipped()
    }

    private func bankDetailColumn(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            Text(label)
                .font(.ftdLabelXS)
                .foregroundStyle(Color.ftdTextTertiary)
            Text(value)
                .font(.ftdLabelMD)
                .foregroundStyle(Color.ftdTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Form Section

    private var formSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                amountField
                transferDateField
            }

            switch viewModel.selectedTab {
            case .bank:
                formTextField(placeholder: String(localized: "UTR ID"), text: $viewModel.utrId)
            case .cash:
                formTextField(placeholder: String(localized: "UTR ID (Optional)"), text: $viewModel.utrId)
            case .cheque:
                HStack(spacing: DesignTokens.Spacing.md) {
                    formTextField(placeholder: String(localized: "Cheque drawn on Bank"), text: $viewModel.chequeDrawnBank)
                    formTextField(placeholder: String(localized: "Cheque number"), text: $viewModel.chequeNo)
                }
            }

            formTextField(placeholder: String(localized: "Remark"), text: $viewModel.remark)

            switch viewModel.selectedTab {
            case .cash:
                InfoBanner(
                    icon: .asset("info"),
                    showIconBackground: true,
                    iconTint: .ftdAccentOrange,
                    iconBackgroundcolor: .ftdBannerOrangeTint,
                    backgroundColor: .ftdBannerOrangeBG,
                    title: "Note",
                    message: "Please send cash deposit slip at admin@ftd.travel"
                )
            case .cheque:
                InfoBanner(
                    icon: .asset("info"),
                    showIconBackground: true,
                    iconTint: .ftdAccentOrange,
                    iconBackgroundcolor: .ftdBannerOrangeTint,
                    backgroundColor: .ftdBannerOrangeBG,
                    title: "Note",
                    message: "Please send cheque deposit slip at admin@ftd.travel"
                )
                
//            case .cheque:
//                InfoBanner(
//                    icon: .system("info.circle.fill"),
//                    title: "Cheque Deposit",
//                    message: "Please send cheque deposit slip at admin@ftd.travel"
//                )
            case .bank:
                EmptyView()
            }
        }
    }

    private var amountField: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            FTDTextField(label: "", placeholder: String(localized: "Amount"), text: $viewModel.amount, keyboardType: .numberPad)
            if viewModel.selectedTab == .cash && !viewModel.cashDailyLimit.isEmpty {
                // Text(String(localized: "Daily limit ₹1,90,000/- per day"))
                Text(viewModel.cashDailyLimit)
                    .font(.ftdLabelXS)
                    .foregroundStyle(Color.ftdOrangeLabel)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var transferDateField: some View {
        let formatted = viewModel.transferDateFormatted
        let pickerDate = Binding<Date>(
            get: { viewModel.transferDate ?? Date() },
            set: { viewModel.transferDate = $0 }
        )
        return Button { showDatePicker = true } label: {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.inputLabelGap) {
                Text(String(localized: "Transfer Date"))
                    .font(.ftdPlaceholder)
                    .foregroundStyle(Color.ftdTextTertiary)
                Text(formatted ?? String(localized: "Select date"))
                    .font(.ftdBodyMD)
                    .foregroundStyle(formatted != nil ? Color.ftdTextPrimary : Color.ftdTextTertiary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .ftdInputContainer(hasError: false)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showDatePicker) {
            VStack(spacing: DesignTokens.Spacing.lg) {
                DatePicker(
                    String(localized: "Transfer Date"),
                    selection: pickerDate,
                    in: ...Date(),
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .tint(Color.ftdAccentOrange)
                .padding(.horizontal, DesignTokens.Spacing.lg)

                FTDPrimaryButton(title: String(localized: "Done")) {
                    showDatePicker = false
                }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.lg)
            }
            .presentationDetents([.medium])
        }
    }

    private func formTextField(placeholder: String, text: Binding<String>) -> some View {
        FTDTextField(label: "", placeholder: placeholder, text: text)
    }

    // MARK: - Instant Top-Up

    private var instantTopUpSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                Text(String(localized: "Amount"))
                    .font(.ftdMenuName)
                    .foregroundStyle(Color.ftdTextPrimary)
                    .padding(.bottom, DesignTokens.Spacing.sm)
                FTDTextField(label: "", placeholder: String(localized: "Amount"), text: $viewModel.amount, keyboardType: .numberPad)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.xl)

            FTDPrimaryButton(
                title: String(localized: "Load Balance"),
                action: { Task { await viewModel.initiateInstantTopUp() } }
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)

            InfoBanner(
                icon: .asset("iconShield"),
                showIconBackground: true,
                title: "Instant TopUp",
                message: "The amount will be added instantly to your wallet balance."
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.top, DesignTokens.Spacing.xl)
        }
    }

    // MARK: - Nimbbl

    @ViewBuilder
    private var nimbblCoverContent: some View {
        if let orderData = viewModel.nimbblOrderData, let token = orderData.paymentToken {
            NavigationStack {
                NimbblCheckoutRepresentable(
                    paymentToken: token,
                    onSuccess: { payload in
                        Task { await viewModel.handleNimbblSuccess(payload: payload) }
                    },
                    onFailure: { payload in
                        viewModel.handleNimbblFailure(payload: payload)
                    }
                )
                .ignoresSafeArea(edges: .bottom)
                .navigationTitle(String(localized: "Secure Payment"))
                .navigationBarTitleDisplayMode(.inline)
                .toolbarBackground(Color.ftdCardBackground, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(String(localized: "Close")) {
                            viewModel.handleNimbblDismiss()
                        }
                        .foregroundStyle(Color.ftdTextPrimary)
                    }
                }
            }
        }
    }

    // MARK: - Loading

    private var centerLoadingView: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            ProgressView()
                .tint(Color.ftdAccentOrange)
                .scaleEffect(1.5)
            Text(String(localized: "Loading..."))
                .font(.ftdBodyMD)
                .foregroundStyle(Color.ftdTextSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var loadingOverlay: some View {
        ZStack {
            Color.black.opacity(0.35).ignoresSafeArea()
            VStack(spacing: DesignTokens.Spacing.lg) {
                ProgressView()
                    .tint(Color.ftdAccentOrange)
                    .scaleEffect(1.5)
                Text(viewModel.loadingMessage)
                    .font(.ftdBodyMD)
                    .foregroundStyle(Color.ftdTextPrimary)
            }
            .padding(DesignTokens.Spacing.xxl)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.cardLg))
        }
    }

    // MARK: - Success View

    private func successView(referenceNo: String, message: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.xxl) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.ftdAccentTeal.opacity(0.12))
                    .frame(width: 100, height: 100)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.ftdAccentTeal)
            }
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text(referenceNo.isEmpty ? String(localized: "Payment Successful") : String(localized: "Request Submitted"))
                    .font(.ftdTitleLG)
                    .foregroundStyle(Color.ftdTextPrimary)
                Text(message)
                    .font(.ftdBodyMD)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.Spacing.xxl)
                if !referenceNo.isEmpty {
                    VStack(spacing: DesignTokens.Spacing.xs) {
                        Text(String(localized: "Reference No"))
                            .font(.ftdPlaceholder)
                            .foregroundStyle(Color.ftdTextSecondary)
                        Text(referenceNo)
                            .font(.ftdLabelSM)
                            .foregroundStyle(Color.ftdTextPrimary)
                            .padding(.horizontal, DesignTokens.Spacing.md)
                            .padding(.vertical, DesignTokens.Spacing.sm)
                            .background(Color.ftdCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
                    }
                    .padding(.top, DesignTokens.Spacing.sm)
                }
            }
            Spacer()
            FTDPrimaryButton(title: String(localized: "Done")) { dismiss() }
                .padding(.horizontal, DesignTokens.Spacing.lg)
                .padding(.bottom, DesignTokens.Spacing.xxxl)
        }
    }

    // MARK: - Failure View

    private func failureView(message: String) -> some View {
        VStack(spacing: DesignTokens.Spacing.xxl) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.ftdDestructiveRed.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(Color.ftdDestructiveRed)
            }
            VStack(spacing: DesignTokens.Spacing.sm) {
                Text(String(localized: "Something went wrong"))
                    .font(.ftdTitleLG)
                    .foregroundStyle(Color.ftdTextPrimary)
                Text(message)
                    .font(.ftdBodyMD)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.Spacing.xxl)
            }
            Spacer()
            VStack(spacing: DesignTokens.Spacing.md) {
                FTDPrimaryButton(title: String(localized: "Retry")) { viewModel.retry() }
                Button(String(localized: "Cancel")) { dismiss() }
                    .font(.ftdBodyMD)
                    .foregroundStyle(Color.ftdTextSecondary)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.xxxl)
        }
    }
}

// MARK: - Field Style

private extension View {
    @ViewBuilder
    func ftdGlassCircle() -> some View {
        if #available(iOS 26.0, *) {
            self
                .glassEffect(.regular.interactive(), in: Circle())
        } else {
            self
                .background(.ultraThinMaterial, in: Circle())
                .overlay {
                    Circle()
                        .stroke(Color.ftdBorder.opacity(0.7), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 4)
        }
    }

    func fieldStyle() -> some View {
        self
            .padding(DesignTokens.Spacing.md)
            .background(Color.ftdCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                    .stroke(Color.ftdBorder, lineWidth: 1)
            )
    }
}

private struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}


//
//[GET] http://13.200.42.214/book/mapp/mapp_b2b/upload_money
//Response [200] /book/mapp/mapp_b2b/upload_money: {"status":true,"message":"Success","data":{"deposit_data_list":[{"transfer_id":"80737","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-Cheque-ICICI","deposit_type":"Cheque","transfer_amount":"15000","mobile_no":"8105020005","transfer_date":"2026-07-27","transaction_id":"","bank_name":"ICICI Bank(2323 0500 0110)","cheque_no":"123456","customer_remarks":"Cheque deposit","status":"PENDING","refund_charge_reason":null,"created_at":"2026-08-13 23:02:19","cheque_drawn_bank":"State Bank of India","credit_pending":"","payment_gateway":"","reference_no":"MM2608131732196886492","request_date":"2026-08-13","remarks":null,"admin_remarks":null,"approver_name":null,"booking":"0"},{"transfer_id":"80736","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-BTB-SBI","deposit_type":"Online Transfer","transfer_amount":"100","mobile_no":"8105020005","transfer_date":"23-Aug-2026","transaction_id":"40044JSAJA34234","bank_name":"SBI (4528 1136 106)","cheque_no":"","customer_remarks":"Test Remarks","status":"PENDING","refund_charge_reason":null,"created_at":"2026-08-12 16:44:37","cheque_drawn_bank":"","credit_pending":"","payment_gateway":"","reference_no":"MM2608121114378730874","request_date":"2026-08-12","remarks":null,"admin_remarks":null,"approver_name":null,"booking":"0"},{"transfer_id":"80731","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-BTB-SBI","deposit_type":"Online Transfer","transfer_amount":"1200","mobile_no":"8105020005","transfer_date":"04-Aug-2026","transaction_id":"123455","bank_name":"SBI (4528 1136 106)","cheque_no":"","customer_remarks":"-","status":"PENDING","refund_charge_reason":null,"created_at":"2026-08-04 16:33:40","cheque_drawn_bank":"","credit_pending":"","payment_gateway":"","reference_no":"MM2608041103409797928","request_date":"2026-08-04","remarks":null,"admin_remarks":null,"approver_name":null,"booking":"0"},{"transfer_id":"80714","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-Cheque-ICICI","deposit_type":"Cheque","transfer_amount":"15000","mobile_no":"8105020005","transfer_date":"2026-07-27","transaction_id":"","bank_name":"ICICI Bank(2323 0500 0110)","cheque_no":"123456","customer_remarks":"Cheque deposit","status":"PENDING","refund_charge_reason":null,"created_at":"2026-07-27 12:20:41","cheque_drawn_bank":"State Bank of India","credit_pending":"","payment_gateway":"","reference_no":"MM2607270650414475365","request_date":"2026-07-27","remarks":null,"admin_remarks":null,"approver_name":null,"booking":"0"},{"transfer_id":"80713","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-Cash-HDFC","deposit_type":"Cash","transfer_amount":"10000","mobile_no":"8105020005","transfer_date":"2026-07-27","transaction_id":"","bank_name":"HDFC Bank(5920 222 111 2222)","cheque_no":"","customer_remarks":"Cash deposited at HDFC branch","status":"PENDING","refund_charge_reason":null,"created_at":"2026-07-27 12:14:38","cheque_drawn_bank":"","credit_pending":"","payment_gateway":"","reference_no":"MM2607270644383080679","request_date":"2026-07-27","remarks":null,"admin_remarks":null,"approver_name":null,"booking":"0"},{"transfer_id":"80712","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-BTB-SBI","deposit_type":"Online Transfer","transfer_amount":"5000","mobile_no":"8105020005","transfer_date":"2026-07-27","transaction_id":"UTR123456789","bank_name":"SBI (4528 1136 106)","cheque_no":"","customer_remarks":"Bank transfer for wallet top-up","status":"PENDING","refund_charge_reason":null,"created_at":"2026-07-27 12:12:23","cheque_drawn_bank":"","credit_pending":"","payment_gateway":"","reference_no":"MM2607270642235130593","request_date":"2026-07-27","remarks":null,"admin_remarks":null,"approver_name":null,"booking":"0"},{"transfer_id":"80635","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-Cheque-SBI","deposit_type":"Cheque","transfer_amount":"12345","mobile_no":"8105020005","transfer_date":"26-Jun-2026","transaction_id":null,"bank_name":"SBI Bank(4528 1136 106)","cheque_no":"987654","customer_remarks":"Cheque Testing icici","status":"DECLINED","refund_charge_reason":null,"created_at":"2026-06-26 12:59:13","cheque_drawn_bank":"ICICI","credit_pending":null,"payment_gateway":null,"reference_no":"MM2606260729131170302","request_date":"2026-06-26","remarks":"","admin_remarks":"not receivd","approver_name":"Vinit Jain","booking":"0"},{"transfer_id":"80634","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-Cash-SBI","deposit_type":"Cash","transfer_amount":"10000","mobile_no":"8105020005","transfer_date":"26-Jun-2026","transaction_id":"1932","bank_name":"SBI Bank(4528 1136 106)","cheque_no":null,"customer_remarks":"CASH TESTING","status":"APPROVED","refund_charge_reason":null,"created_at":"2026-06-26 12:58:24","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2606260728248372244","request_date":"2026-06-26","remarks":"checking","admin_remarks":"","approver_name":"Vinit Jain","booking":"0"},{"transfer_id":"80633","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-BTB-SBI","deposit_type":"Online Transfer","transfer_amount":"2000","mobile_no":"8105020005","transfer_date":"26-Jun-2026","transaction_id":"testing","bank_name":"SBI Bank(4528 1136 106)","cheque_no":null,"customer_remarks":"testing 2k sbi def date","status":"APPROVED","refund_charge_reason":null,"created_at":"2026-06-26 12:56:06","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2606260726063409193","request_date":"2026-06-26","remarks":"","admin_remarks":"","approver_name":"Vinit Jain","booking":"0"},{"transfer_id":"80632","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-BTB-SBI","deposit_type":"Online Transfer","transfer_amount":"10000","mobile_no":"8105020005","transfer_date":"01-Jun-2026","transaction_id":"Test UTR","bank_name":"","cheque_no":null,"customer_remarks":"Testing SBI","status":"APPROVED","refund_charge_reason":null,"created_at":"2026-06-26 11:43:40","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2606260613407719262","request_date":"2026-06-26","remarks":"","admin_remarks":"","approver_name":"Vinit Jain","booking":"0"},{"transfer_id":"80473","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":null,"deposit_type":"Online Transfer","transfer_amount":"1000","mobile_no":"8105020005","transfer_date":"25-Nov-2025","transaction_id":"MM2511254930692","bank_name":"ICICI Bank(2323 0500 0110)","cheque_no":null,"customer_remarks":"Testing ","status":"PENDING","refund_charge_reason":null,"created_at":"2025-11-25 18:01:57","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2511254930692","request_date":"2025-11-25","remarks":null,"admin_remarks":null,"approver_name":null,"booking":"0"},{"transfer_id":"80470","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-BTB-ICICI","deposit_type":"Online Transfer","transfer_amount":"100","mobile_no":"8105020005","transfer_date":"19-Nov-2025","transaction_id":"7654","bank_name":"ICICI Bank(2323 0500 0110)","cheque_no":null,"customer_remarks":"testing","status":"PENDING","refund_charge_reason":null,"created_at":"2025-11-19 14:59:21","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2511190929211265293","request_date":"2025-11-19","remarks":null,"admin_remarks":null,"approver_name":null,"booking":"0"},{"transfer_id":"80469","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-BTB-ICICI","deposit_type":"Online Transfer","transfer_amount":"2000","mobile_no":"8105020005","transfer_date":"19-Nov-2025","transaction_id":"40044400044443","bank_name":"ICICI Bank(2323 0500 0110)","cheque_no":null,"customer_remarks":"Testing","status":"PENDING","refund_charge_reason":null,"created_at":"2025-11-19 11:41:42","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2511190611424265720","request_date":"2025-11-19","remarks":null,"admin_remarks":null,"approver_name":null,"booking":"0"},{"transfer_id":"80468","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-BTB-ICICI","deposit_type":"Online Transfer","transfer_amount":"1000","mobile_no":"8105020005","transfer_date":"17-Dec-2025","transaction_id":"400444000444","bank_name":"ICICI Bank(2323 0500 0110)","cheque_no":null,"customer_remarks":"Test","status":"PENDING","refund_charge_reason":null,"created_at":"2025-11-19 11:01:45","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2511190531457810715","request_date":"2025-11-19","remarks":null,"admin_remarks":null,"approver_name":null,"booking":"0"},{"transfer_id":"80242","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":null,"deposit_type":"Online Transfer","transfer_amount":"10000","mobile_no":"8105020005","transfer_date":"29-May-2025","transaction_id":"1234","bank_name":"QR Code(ICICI Bank)","cheque_no":null,"customer_remarks":"test","status":"APPROVED","refund_charge_reason":null,"created_at":"2025-05-27 17:42:30","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2505272105332","request_date":"2025-05-27","remarks":"","admin_remarks":"","approver_name":"Vinit Jain","booking":"0"},{"transfer_id":"80233","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-UPI-ICICI","deposit_type":"Online Transfer","transfer_amount":"250","mobile_no":"8105020005","transfer_date":"20-Apr-2025","transaction_id":"123454367","bank_name":"ICICI Bank(2323 0500 0110)","cheque_no":null,"customer_remarks":"Test Upi","status":"APPROVED","refund_charge_reason":null,"created_at":"2025-04-21 18:01:42","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2504211231426546612","request_date":"2025-04-21","remarks":"","admin_remarks":"","approver_name":"Vinit Jain","booking":"0"},{"transfer_id":"80232","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":null,"deposit_type":"Reduce Credit","transfer_amount":"1000","mobile_no":"8105020005","transfer_date":null,"transaction_id":null,"bank_name":null,"cheque_no":null,"customer_remarks":"Reduce check","status":"APPROVED","refund_charge_reason":null,"created_at":"2025-04-21 17:58:51","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2504218990687","request_date":"2025-04-21","remarks":"","admin_remarks":"","approver_name":"Vinit Jain","booking":"0"},{"transfer_id":"80231","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":null,"deposit_type":"Credit Request","transfer_amount":"100000","mobile_no":"8105020005","transfer_date":null,"transaction_id":null,"bank_name":null,"cheque_no":null,"customer_remarks":"Testin","status":"PENDING","refund_charge_reason":null,"created_at":"2025-04-21 17:57:02","cheque_drawn_bank":null,"credit_pending":"600000","payment_gateway":null,"reference_no":"MM2504219351716","request_date":"2025-04-21","remarks":null,"admin_remarks":null,"approver_name":null,"booking":"0"},{"transfer_id":"80230","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-BTB-ICICI","deposit_type":"Online Transfer","transfer_amount":"1000","mobile_no":"8105020005","transfer_date":"21-Apr-2025","transaction_id":"123456789","bank_name":"ICICI Bank(2323 0500 0110)","cheque_no":null,"customer_remarks":"Test Remarks","status":"APPROVED","refund_charge_reason":null,"created_at":"2025-04-21 17:56:10","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2504211226109516155","request_date":"2025-04-21","remarks":"test credit adjust","admin_remarks":"","approver_name":"Vinit Jain","booking":"0"},{"transfer_id":"80229","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-Cash-ICICI","deposit_type":"Cash","transfer_amount":"2000","mobile_no":"8105020005","transfer_date":"21-Apr-2025","transaction_id":"123456789","bank_name":"ICICI Bank(2323 0500 0110)","cheque_no":null,"customer_remarks":"Test Cash Deposit","status":"PENDING","refund_charge_reason":null,"created_at":"2025-04-21 17:55:15","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2504211225158764292","request_date":"2025-04-21","remarks":null,"admin_remarks":null,"approver_name":null,"booking":"0"},{"transfer_id":"80228","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-Cash-ICICI","deposit_type":"Cash","transfer_amount":"2000","mobile_no":"8105020005","transfer_date":"21-Apr-2025","transaction_id":"123456789","bank_name":"ICICI Bank(2323 0500 0110)","cheque_no":null,"customer_remarks":"Test Cash Deposit","status":"DECLINED","refund_charge_reason":null,"created_at":"2025-04-21 17:54:44","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2504211224444402350","request_date":"2025-04-21","remarks":"","admin_remarks":"testing","approver_name":"Vinit Jain","booking":"0"},{"transfer_id":"80227","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":"OR-Cash-ICICI","deposit_type":"Cash","transfer_amount":"1000","mobile_no":"8105020005","transfer_date":"21-Apr-2025","transaction_id":"123456789","bank_name":"ICICI Bank(2323 0500 0110)","cheque_no":null,"customer_remarks":"Advance Payment","status":"APPROVED","refund_charge_reason":null,"created_at":"2025-04-21 17:48:41","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2504211218411636768","request_date":"2025-04-21","remarks":"","admin_remarks":"","approver_name":"Vinit Jain","booking":"0"},{"transfer_id":"80220","agent_id":"7","agent_no":"SMSA18012166","agency_name":"FTD Travel","dist_id":null,"dist_no":null,"dist_name":null,"pay_method":null,"deposit_type":"Online Transfer","transfer_amount":"1000","mobile_no":"8105020005","transfer_date":"17-Apr-2025","transaction_id":"342566","bank_name":"HDFC Bank(5920 222 111 2222)","cheque_no":null,"customer_remarks":"Test","status":"APPROVED","refund_charge_reason":null,"created_at":"2025-04-17 15:10:40","cheque_drawn_bank":null,"credit_pending":null,"payment_gateway":null,"reference_no":"MM2504174617543","request_date":"2025-04-17","remarks":"","admin_remarks":"","approver_name":"Vinit Jain","booking":"0"}],"pendingdata":[{"amount":"645811","count":"90"}],"bank_list":{"bank":[{"bank_id":"1","bank_name":"SBI Bank","account_name":"Shubh Mani Solutions Pvt Ltd","bank_pay_method":"OR-BTB-SBI","cash_pay_method":"OR-Cash-SBI","cheque_pay_method":"OR-Cheque-SBI","account_no":"4528 1136 106","ifsc_code":"SBIN 000 6198","branch":"Rajaji Nagar 1st Block Bhasyam Circle, Bangalore, Karnataka","show_bank":"1","bank_order":"1","show_cash":"1","cash_order":"1","show_cheque":"1","cheque_order":"1","status":"1","bank_logo":"http:\/\/cdn.ftd.travel\/book\/public\/img\/logoSBI.svg","bank_remarks":null,"cash_remarks":null,"cheque_remarks":null},{"bank_id":"2","bank_name":"HDFC Bank","account_name":"Shubh Mani Solutions Pvt Ltd","bank_pay_method":"OR-BTB-HDFC","cash_pay_method":"OR-Cash-HDFC","cheque_pay_method":"OR-Cheque-HDFC","account_no":"5920 222 111 2222","ifsc_code":"HDFC 000 1373","branch":"Bhasyam Circle, Rajaji Nagar, Bangalore, Karnataka","show_bank":"1","bank_order":"2","show_cash":"1","cash_order":"3","show_cheque":"1","cheque_order":"3","status":"1","bank_logo":"http:\/\/cdn.ftd.travel\/book\/public\/img\/logoHDFC.svg","bank_remarks":null,"cash_remarks":"Do Not Use","cheque_remarks":null},{"bank_id":"3","bank_name":"ICICI Bank","account_name":"Shubh Mani Solutions Pvt Ltd","bank_pay_method":"OR-BTB-ICICI","cash_pay_method":"OR-Cash-ICICI","cheque_pay_method":"OR-Cheque-ICICI","account_no":"2323 0500 0110","ifsc_code":"ICIC 000 2323","branch":"Rajaji Nagar 1st Block Bhasyam Circle, Bangalore, Karnataka","show_bank":"1","bank_order":"3","show_cash":"1","cash_order":"2","show_cheque":"1","cheque_order":"2","status":"1","bank_logo":"http:\/\/cdn.ftd.travel\/book\/public\/img\/logoICICI.svg","bank_remarks":"Do not use till further notice","cash_remarks":"Do not use till further notice","cheque_remarks":"Do not use till further notice"}],"cash":[{"bank_id":"1","bank_name":"SBI Bank","account_name":"Shubh Mani Solutions Pvt Ltd","bank_pay_method":"OR-BTB-SBI","cash_pay_method":"OR-Cash-SBI","cheque_pay_method":"OR-Cheque-SBI","account_no":"4528 1136 106","ifsc_code":"SBIN 000 6198","branch":"Rajaji Nagar 1st Block Bhasyam Circle, Bangalore, Karnataka","show_bank":"1","bank_order":"1","show_cash":"1","cash_order":"1","show_cheque":"1","cheque_order":"1","status":"1","bank_logo":"http:\/\/cdn.ftd.travel\/book\/public\/img\/logoSBI.svg","bank_remarks":null,"cash_remarks":null,"cheque_remarks":null},{"bank_id":"3","bank_name":"ICICI Bank","account_name":"Shubh Mani Solutions Pvt Ltd","bank_pay_method":"OR-BTB-ICICI","cash_pay_method":"OR-Cash-ICICI","cheque_pay_method":"OR-Cheque-ICICI","account_no":"2323 0500 0110","ifsc_code":"ICIC 000 2323","branch":"Rajaji Nagar 1st Block Bhasyam Circle, Bangalore, Karnataka","show_bank":"1","bank_order":"3","show_cash":"1","cash_order":"2","show_cheque":"1","cheque_order":"2","status":"1","bank_logo":"http:\/\/cdn.ftd.travel\/book\/public\/img\/logoICICI.svg","bank_remarks":"Do not use till further notice","cash_remarks":"Do not use till further notice","cheque_remarks":"Do not use till further notice"},{"bank_id":"2","bank_name":"HDFC Bank","account_name":"Shubh Mani Solutions Pvt Ltd","bank_pay_method":"OR-BTB-HDFC","cash_pay_method":"OR-Cash-HDFC","cheque_pay_method":"OR-Cheque-HDFC","account_no":"5920 222 111 2222","ifsc_code":"HDFC 000 1373","branch":"Bhasyam Circle, Rajaji Nagar, Bangalore, Karnataka","show_bank":"1","bank_order":"2","show_cash":"1","cash_order":"3","show_cheque":"1","cheque_order":"3","status":"1","bank_logo":"http:\/\/cdn.ftd.travel\/book\/public\/img\/logoHDFC.svg","bank_remarks":null,"cash_remarks":"Do Not Use","cheque_remarks":null}],"cheque":[{"bank_id":"1","bank_name":"SBI Bank","account_name":"Shubh Mani Solutions Pvt Ltd","bank_pay_method":"OR-BTB-SBI","cash_pay_method":"OR-Cash-SBI","cheque_pay_method":"OR-Cheque-SBI","account_no":"4528 1136 106","ifsc_code":"SBIN 000 6198","branch":"Rajaji Nagar 1st Block Bhasyam Circle, Bangalore, Karnataka","show_bank":"1","bank_order":"1","show_cash":"1","cash_order":"1","show_cheque":"1","cheque_order":"1","status":"1","bank_logo":"http:\/\/cdn.ftd.travel\/book\/public\/img\/logoSBI.svg","bank_remarks":null,"cash_remarks":null,"cheque_remarks":null},{"bank_id":"3","bank_name":"ICICI Bank","account_name":"Shubh Mani Solutions Pvt Ltd","bank_pay_method":"OR-BTB-ICICI","cash_pay_method":"OR-Cash-ICICI","cheque_pay_method":"OR-Cheque-ICICI","account_no":"2323 0500 0110","ifsc_code":"ICIC 000 2323","branch":"Rajaji Nagar 1st Block Bhasyam Circle, Bangalore, Karnataka","show_bank":"1","bank_order":"3","show_cash":"1","cash_order":"2","show_cheque":"1","cheque_order":"2","status":"1","bank_logo":"http:\/\/cdn.ftd.travel\/book\/public\/img\/logoICICI.svg","bank_remarks":"Do not use till further notice","cash_remarks":"Do not use till further notice","cheque_remarks":"Do not use till further notice"},{"bank_id":"2","bank_name":"HDFC Bank","account_name":"Shubh Mani Solutions Pvt Ltd","bank_pay_method":"OR-BTB-HDFC","cash_pay_method":"OR-Cash-HDFC","cheque_pay_method":"OR-Cheque-HDFC","account_no":"5920 222 111 2222","ifsc_code":"HDFC 000 1373","branch":"Bhasyam Circle, Rajaji Nagar, Bangalore, Karnataka","show_bank":"1","bank_order":"2","show_cash":"1","cash_order":"3","show_cheque":"1","cheque_order":"3","status":"1","bank_logo":"http:\/\/cdn.ftd.travel\/book\/public\/img\/logoHDFC.svg","bank_remarks":null,"cash_remarks":"Do Not Use","cheque_remarks":null}]},"sp_cash":"11000","sp_flight":"1092144","sp_bus":"21","sp_recharge":"29284","sp_online":"24250","sp_upi":0,"sp_credit":0,"sp_debit":0,"sp_netbanking":0,"sp_mobile":0,"sp_cashcard":0,"sp_upiwallet":0,"sp_upicc":0,"sp_imps":0,"sp_reward":0,"sp_rupay":0,"sp_others":1182006,"upload_timings":{"start_time":"9 AM","end_time":"9 PM"},"special_message":""}}
