import SwiftUI

struct UploadMoneyView: View {
    @Bindable var viewModel: UploadMoneyViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.ftdInputBackground.ignoresSafeArea()
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
                            .frame(width: 44, height: 44)
                            .ftdGlassCircle()
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(String(localized: "Back"))
                }
            }
            .alert(String(localized: "Error"), isPresented: Binding(
                get: { viewModel.alertMessage != nil },
                set: { if !$0 { viewModel.alertMessage = nil } }
            )) {
                Button(String(localized: "OK")) { viewModel.alertMessage = nil }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
        }
        .task {
            viewModel.reset()
            await viewModel.fetchData()
        }
        .fullScreenCover(isPresented: Binding(
            get: { viewModel.isNimbblPresented },
            set: { if !$0 { viewModel.handleNimbblDismiss() } }
        )) {
            nimbblCoverContent
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
            VStack(spacing: DesignTokens.Spacing.lg) {
                walletBalanceCard
                paymentTypeSection
                if !viewModel.specialMessage.isEmpty {
                    InfoBanner(
                        icon: .system("info.circle.fill"),
                        title: "Notice",
                        message: LocalizedStringKey(viewModel.specialMessage)
                    )
                    .padding(.horizontal, DesignTokens.Spacing.lg)
                }
                if viewModel.paymentType == .offlineRequest {
                    offlineRequestSection
                } else {
                    instantTopUpSection
                }
            }
            .padding(.bottom, DesignTokens.Spacing.xxxl)
        }
        .overlay {
            if viewModel.isLoading {
                loadingOverlay
            }
        }
    }

    // MARK: - Wallet Balance Card

    private var walletBalanceCard: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                LinearGradient(
                    colors: [
                        Color.ftdCardBackground,
                        Color.ftdAccentOrange.opacity(0.08)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Image("")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.08)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()

                walletTravelIllustration
                    .foregroundStyle(Color.ftdAccentOrange.opacity(0.36))
                    .frame(width: 220, height: 120)
                    .offset(x: 12, y: 16)
                    .allowsHitTesting(false)

                VStack(alignment: .leading, spacing: DesignTokens.Spacing.md) {
                    HStack(spacing: DesignTokens.Spacing.md) {
                        iconTile {
                            Image("wallet")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 26, height: 26)
                        }

                        Text(String(localized: "Wallet Balance"))
                            .font(.ftdSectionHeaderMedium)
                            .foregroundStyle(Color.ftdTextSecondary)
                    }

                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        Text(viewModel.walletBalance)
                            .font(.system(size: 34, weight: .bold))
                            .foregroundStyle(Color.ftdTextPrimary)
                            .minimumScaleFactor(0.75)
                            .lineLimit(1)

                        Text(String(localized: "Available Balance"))
                            .font(.ftdButton)
                            .foregroundStyle(Color.ftdTextSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, DesignTokens.Spacing.xxl)
                .padding(.vertical, DesignTokens.Spacing.xxl)
            }
            .frame(height: 240)

            HStack(spacing: 0) {
                pendingStat(
                    icon: "doc",
                    label: String(localized: "Pending Request"),
                    value: "#\(viewModel.pendingCount)",
                    usesAssetIcon: true
                )

                Rectangle()
                    .fill(Color.ftdBorder.opacity(0.7))
                    .frame(width: 1, height: 70)

                pendingStat(
                    icon: "indianrupeesign",
                    label: String(localized: "Pending Amount"),
                    value: viewModel.pendingAmount
                )
            }
            .padding(.vertical, DesignTokens.Spacing.xxl)
            .background(Color.ftdCardBackground)
        }
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 0))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color.ftdBorder.opacity(0.5))
                .frame(height: 1)
        }
        .padding(.top, DesignTokens.Spacing.md)
    }

    private func pendingStat(icon: String, label: String, value: String, usesAssetIcon: Bool = false) -> some View {
        HStack(spacing: DesignTokens.Spacing.lg) {
            iconTile {
                if usesAssetIcon {
                    Image(icon)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                } else {
                    Image(systemName: icon)
                        .font(.system(size: 26, weight: .medium))
                }
            }

            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
                Text(label)
                    .font(.ftdBodySM)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                Text(value)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(Color.ftdTextPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.xxl)
        .frame(maxWidth: .infinity)
    }

    private func iconTile<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .foregroundStyle(Color.ftdAccentOrange)
            .frame(width: 52, height: 52)
            .background(Color.ftdCardBackground.opacity(0.7))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
            .overlay {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                    .stroke(Color.ftdAccentOrange.opacity(0.28), lineWidth: 1)
            }
    }

    private var walletTravelIllustration: some View {
        HStack(alignment: .bottom, spacing: 10) {
            skylineTower(width: 24, height: 110)
            skylineDome
            skylineTower(width: 18, height: 88)
            skylineBuilding(width: 36, height: 58)
            skylineBuilding(width: 44, height: 44)
        }
        .overlay(alignment: .topTrailing) {
            UnevenRoundedRectangle(topLeadingRadius: 30, bottomLeadingRadius: 30)
                .stroke(Color.ftdAccentOrange.opacity(0.42), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .frame(width: 160, height: 32)
                .rotationEffect(.degrees(14))
                .offset(x: 36, y: -24)
        }
    }

    private func skylineTower(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .frame(width: width * 0.2, height: height * 0.12)
            Triangle()
                .frame(width: width * 0.55, height: height * 0.14)
            RoundedRectangle(cornerRadius: width * 0.5)
                .frame(width: width, height: height * 0.74)
        }
    }

    private var skylineDome: some View {
        VStack(spacing: 0) {
            Circle()
                .trim(from: 0, to: 0.5)
                .frame(width: 72, height: 44)
            Rectangle()
                .frame(width: 86, height: 42)
        }
    }

    private func skylineBuilding(width: CGFloat, height: CGFloat) -> some View {
        VStack(spacing: 0) {
            Triangle()
                .frame(width: width * 0.8, height: height * 0.28)
            Rectangle()
                .frame(width: width, height: height * 0.72)
        }
    }

    // MARK: - Payment Type

    private var paymentTypeSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Select Payment Type"))
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextPrimary)
                .padding(.horizontal, DesignTokens.Spacing.lg)

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
            .padding(.horizontal, DesignTokens.Spacing.lg)
        }
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
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextPrimary)
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
            bankListSection
            formSection
                .padding(.horizontal, DesignTokens.Spacing.lg)
            FTDPrimaryButton(
                title: viewModel.selectedTab.submitTitle,
                action: { Task { await viewModel.submitOfflineRequest() } }
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)
            if !viewModel.uploadTimingsText.isEmpty {
                Text(String(localized: "Upload timings: \(viewModel.uploadTimingsText)"))
                    .font(.caption)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, DesignTokens.Spacing.lg)
            }
        }
    }

    private var offlineTabBar: some View {
        HStack(spacing: 0) {
            ForEach(UploadMoneyViewModel.OfflineTab.allCases, id: \.self) { tab in
                Button { viewModel.selectTab(tab) } label: {
                    Text(tab.title)
                        .font(.subheadline)
                        .fontWeight(viewModel.selectedTab == tab ? .semibold : .regular)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DesignTokens.Spacing.sm)
                        .background(viewModel.selectedTab == tab ? Color.ftdAccentOrange : Color.clear)
                        .foregroundStyle(viewModel.selectedTab == tab ? .white : Color.ftdTextSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.button))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.button)
                .stroke(Color.ftdBorder, lineWidth: 1)
        )
        .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: viewModel.selectedTab)
    }

    // MARK: - Bank List

    private var bankListSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Select one of the option"))
                .font(.subheadline).fontWeight(.semibold)
                .foregroundStyle(Color.ftdTextPrimary)
                .padding(.horizontal, DesignTokens.Spacing.lg)

            VStack(spacing: DesignTokens.Spacing.sm) {
                ForEach(viewModel.currentBanks) { bank in
                    bankCard(bank)
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
        }
    }

    private func bankCard(_ bank: BankItem) -> some View {
        let isSelected = viewModel.selectedBankId == bank.bankId
        let isDisabled = viewModel.isDisabled(bank)
        let remark = viewModel.remark(for: bank)

        return Button { viewModel.selectBank(bank) } label: {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
                HStack(alignment: .top, spacing: DesignTokens.Spacing.md) {
                    bankLogo(bank)

                    VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
                        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                            bankDetailColumn(label: String(localized: "Bank"), value: bank.bankName)
                            bankDetailColumn(label: String(localized: "Name"), value: bank.accountName)
                        }
                        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
                            bankDetailColumn(label: String(localized: "Current Account"), value: bank.accountNo)
                            bankDetailColumn(label: String(localized: "IFSC Code"), value: bank.ifscCode)
                        }
                    }
                    .frame(maxWidth: .infinity)

                    ZStack {
                        Circle()
                            .stroke(isSelected ? Color.ftdAccentOrange : Color.ftdBorder, lineWidth: 1.5)
                            .frame(width: 20, height: 20)
                        if isSelected {
                            Circle()
                                .fill(Color.ftdAccentOrange)
                                .frame(width: 12, height: 12)
                        }
                    }
                }

                if let remark, !remark.isEmpty {
                    HStack(spacing: DesignTokens.Spacing.xs) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .font(.caption)
                            .foregroundStyle(Color.ftdAccentOrange)
                        Text(remark)
                            .font(.caption)
                            .foregroundStyle(Color.ftdAccentOrange)
                    }
                }
            }
            .padding(DesignTokens.Spacing.md)
            .background(Color.ftdCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                    .stroke(
                        isSelected ? Color.ftdAccentOrange : Color.ftdBorder,
                        lineWidth: isSelected ? 1.5 : 1
                    )
            )
            .opacity(isDisabled ? 0.5 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: isSelected)
    }

    private func bankLogo(_ bank: BankItem) -> some View {
        let url = bank.bankLogo.flatMap { URL(string: $0) }
        return FTDRemoteImage(url: url) {
            ZStack {
                RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                    .fill(Color.ftdAccentOrange.opacity(0.12))
                Text(String(bank.bankName.prefix(1)))
                    .font(.headline).fontWeight(.bold)
                    .foregroundStyle(Color.ftdAccentOrange)
            }
        }
        .frame(width: 44, height: 44)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
    }

    private func bankDetailColumn(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxs) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(Color.ftdTextSecondary)
            Text(value)
                .font(.caption).fontWeight(.medium)
                .foregroundStyle(Color.ftdTextPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Form Section

    @ViewBuilder
    private var formSection: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            HStack(spacing: DesignTokens.Spacing.md) {
                amountField
                transferDateField
            }

            switch viewModel.selectedTab {
            case .bank:
                formTextField(placeholder: String(localized: "UTR ID"), text: $viewModel.utrId)
            case .cash:
                formTextField(placeholder: String(localized: "UTR ID (Optional)"), text: $viewModel.utrId)
                InfoBanner(
                    icon: .system("info.circle.fill"),
                    title: "Cash Deposit",
                    message: "Please send cash deposit slip at admin@ftd.travel"
                )
            case .cheque:
                HStack(spacing: DesignTokens.Spacing.md) {
                    formTextField(placeholder: String(localized: "Cheque drawn on Bank"), text: $viewModel.chequeDrawnBank)
                    formTextField(placeholder: String(localized: "Cheque number"), text: $viewModel.chequeNo)
                }
                InfoBanner(
                    icon: .system("info.circle.fill"),
                    title: "Cheque Deposit",
                    message: "Please send cheque deposit slip at admin@ftd.travel"
                )
            }

            formTextField(placeholder: String(localized: "Remark"), text: $viewModel.remark)
        }
    }

    private var amountField: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            TextField(String(localized: "Amount"), text: $viewModel.amount)
                .keyboardType(.numberPad)
                .fieldStyle()
            if viewModel.selectedTab == .cash {
                Text(String(localized: "Daily limit ₹1,00,000/- per day"))
                    .font(.caption2)
                    .foregroundStyle(Color.ftdTextSecondary)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var transferDateField: some View {
        DatePicker("", selection: $viewModel.transferDate, displayedComponents: .date)
            .datePickerStyle(.compact)
            .labelsHidden()
            .frame(maxWidth: .infinity)
            .padding(DesignTokens.Spacing.md)
            .background(Color.ftdCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                    .stroke(Color.ftdBorder, lineWidth: 1)
            )
    }

    private func formTextField(placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .fieldStyle()
            .frame(maxWidth: .infinity)
    }

    // MARK: - Instant Top-Up

    private var instantTopUpSection: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            TextField(String(localized: "Amount"), text: $viewModel.amount)
                .keyboardType(.numberPad)
                .fieldStyle()
                .padding(.horizontal, DesignTokens.Spacing.lg)

            FTDPrimaryButton(
                title: String(localized: "Load Balance"),
                action: { Task { await viewModel.initiateInstantTopUp() } }
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)

            InfoBanner(
                icon: .system("shield.checkered"),
                showIconBackground: true,
                title: "Instant TopUp",
                message: "The amount will be added instantly to your wallet balance."
            )
            .padding(.horizontal, DesignTokens.Spacing.lg)
        }
    }

    // MARK: - Nimbbl

    @ViewBuilder
    private var nimbblCoverContent: some View {
        if let orderData = viewModel.nimbblOrderData, let token = orderData.paymentToken {
            NimbblCheckoutRepresentable(
                orderToken: token,
                onSuccess: { payload in
                    Task { await viewModel.handleNimbblSuccess(payload: payload) }
                },
                onFailure: { payload in
                    viewModel.handleNimbblFailure(payload: payload)
                }
            )
            .ignoresSafeArea()
        }
    }

    // MARK: - Loading

    private var centerLoadingView: some View {
        VStack(spacing: DesignTokens.Spacing.lg) {
            ProgressView()
                .tint(Color.ftdAccentOrange)
                .scaleEffect(1.5)
            Text(String(localized: "Loading..."))
                .font(.subheadline)
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
                    .font(.subheadline)
                    .foregroundStyle(.white)
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
                Text(String(localized: "Request Submitted"))
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(Color.ftdTextPrimary)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.Spacing.xxl)
                if !referenceNo.isEmpty {
                    VStack(spacing: DesignTokens.Spacing.xs) {
                        Text(String(localized: "Reference No"))
                            .font(.caption)
                            .foregroundStyle(Color.ftdTextSecondary)
                        Text(referenceNo)
                            .font(.subheadline).fontWeight(.semibold)
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
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(Color.ftdTextPrimary)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.Spacing.xxl)
            }
            Spacer()
            VStack(spacing: DesignTokens.Spacing.md) {
                FTDPrimaryButton(title: String(localized: "Retry")) { viewModel.retry() }
                Button(String(localized: "Cancel")) { dismiss() }
                    .font(.subheadline)
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
