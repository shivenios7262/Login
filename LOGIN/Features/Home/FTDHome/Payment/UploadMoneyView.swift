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
            .navigationTitle("Upload Money")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(Color.ftdTextSecondary)
                    }
                }
            }
            .disabled(viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    loadingOverlay
                }
            }
        }
        .onAppear { viewModel.reset() }
        .fullScreenCover(
            isPresented: Binding(
                get: { viewModel.isNimbblPresented },
                set: { if !$0 { viewModel.handleNimbblDismiss() } }
            )
        ) {
            nimbblCoverContent
        }
    }

    // MARK: - Main Content

    @ViewBuilder
    private var mainContent: some View {
        switch viewModel.phase {
        case .success(let message):
            successView(message: message)
        case .failure(let message):
            failureView(message: message)
        default:
            paymentForm
        }
    }

    // MARK: - Payment Form

    private var paymentForm: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: DesignTokens.Spacing.xxl) {
                paymentIllustration
                amountSection
                paymentMethodBadge
                FTDPrimaryButton(
                    title: "Pay Now",
                    leadingIcon: "creditcard.fill",
                    action: { Task { await viewModel.initiatePayment() } }
                )
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.vertical, DesignTokens.Spacing.xxl)
        }
    }

    private var paymentIllustration: some View {
        VStack(spacing: DesignTokens.Spacing.md) {
            ZStack {
                Circle()
                    .fill(Color.ftdAccentOrange.opacity(0.1))
                    .frame(width: 90, height: 90)
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 46))
                    .foregroundStyle(Color.ftdAccentOrange)
            }
            .padding(.top, DesignTokens.Spacing.lg)
            Text("Add Funds to Your Wallet")
                .font(.headline).fontWeight(.bold)
                .foregroundStyle(Color.ftdTextPrimary)
            Text("Securely top up your travel agent account balance via online payment.")
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.sm) {
            Text("Enter Amount (₹)")
                .font(.caption)
                .foregroundStyle(Color.ftdTextSecondary)
                .textCase(.uppercase)
                .tracking(0.5)

            HStack(spacing: DesignTokens.Spacing.sm) {
                Text("₹")
                    .font(.title2).fontWeight(.semibold)
                    .foregroundStyle(Color.ftdTextPrimary)
                TextField("0", text: $viewModel.amountText)
                    .keyboardType(.numberPad)
                    .font(.title2).fontWeight(.semibold)
                    .foregroundStyle(Color.ftdTextPrimary)
            }
            .padding(DesignTokens.Spacing.lg)
            .background(Color.ftdCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
            .overlay(
                RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                    .stroke(Color.ftdAccentOrange.opacity(0.4), lineWidth: 1.5)
            )

            quickAmountRow
        }
    }

    private var quickAmountRow: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            ForEach(["500", "1000", "5000", "10000"], id: \.self) { preset in
                Button { viewModel.amountText = preset } label: {
                    Text("₹\(preset)")
                        .font(.caption).fontWeight(.medium)
                        .padding(.horizontal, DesignTokens.Spacing.md)
                        .padding(.vertical, DesignTokens.Spacing.sm)
                        .background(
                            viewModel.amountText == preset
                                ? Color.ftdAccentOrange.opacity(0.15)
                                : Color.ftdCardBackground
                        )
                        .foregroundStyle(
                            viewModel.amountText == preset
                                ? Color.ftdAccentOrange
                                : Color.ftdTextSecondary
                        )
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(
                                viewModel.amountText == preset
                                    ? Color.ftdAccentOrange.opacity(0.5)
                                    : Color.ftdBorder,
                                lineWidth: 1
                            )
                        )
                }
                .buttonStyle(.plain)
                .animation(.easeInOut(duration: DesignTokens.Animation.fast), value: viewModel.amountText)
            }
        }
    }

    private var paymentMethodBadge: some View {
        HStack(spacing: DesignTokens.Spacing.sm) {
            Image(systemName: "lock.shield.fill")
                .foregroundStyle(Color.ftdAccentTeal)
            Text("Secure payment powered by Nimbbl")
                .font(.subheadline)
                .foregroundStyle(Color.ftdTextSecondary)
            Spacer()
        }
        .padding(DesignTokens.Spacing.md)
        .background(Color.ftdCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.card))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.card)
                .stroke(Color.ftdBorder, lineWidth: 1)
        )
    }

    // MARK: - Nimbbl Checkout Cover

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

    // MARK: - Loading Overlay

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

    private func successView(message: String) -> some View {
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
                Text("Payment Successful")
                    .font(.title2).fontWeight(.bold)
                    .foregroundStyle(Color.ftdTextPrimary)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignTokens.Spacing.xxl)
            }
            Spacer()
            FTDPrimaryButton(title: "Done") { dismiss() }
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
                Text("Payment Failed")
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
                FTDPrimaryButton(title: "Try Again") { viewModel.retry() }
                Button("Cancel") { dismiss() }
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
            }
            .padding(.horizontal, DesignTokens.Spacing.lg)
            .padding(.bottom, DesignTokens.Spacing.xxxl)
        }
    }
}
