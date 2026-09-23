import SwiftUI

struct SignUpView: View {
    private let authManager: AuthManager
    private let onSuccess: () -> Void
    @State private var viewModel: SignUpViewModel
    @State private var showTerms = false

    private enum Layout {
        static let fieldSpacing: CGFloat           = DesignTokens.Spacing.fieldSpacing
        static let pairedSpacing: CGFloat          = DesignTokens.Spacing.md
        static let titleFieldMaxWidth: CGFloat     = 100
        static let errorCornerRadius: CGFloat      = DesignTokens.Radius.field
        static let errorVerticalPadding: CGFloat   = DesignTokens.Spacing.inputVertical
        static let errorHorizontalPadding: CGFloat = DesignTokens.Spacing.inputHorizontal
    }

    init(authManager: AuthManager, onSuccess: @escaping () -> Void) {
        self.authManager = authManager
        self.onSuccess = onSuccess
        _viewModel = State(initialValue: SignUpViewModel(authManager: authManager))
    }

    var body: some View {
        if viewModel.isRegistered {
            thankYouView
        } else {
            formView
        }
    }

    // MARK: - Thank You View

    private var thankYouView: some View {
        VStack(spacing: DesignTokens.Spacing.xl) {
            registrationIcon

            VStack(spacing: DesignTokens.Spacing.xs) {
                Text(String(localized: "Thank you for registering with us!"))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.ftdAccentTeal)
                    .multilineTextAlignment(.center)

                Text(String(localized: "Your account details are as follows:"))
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
            }

            accountDetailsCard

            documentsSection

            Text(String(localized: "Do check your email for complete details."))
                .font(.footnote)
                .foregroundStyle(Color.ftdTextSecondary)
                .multilineTextAlignment(.center)

            Button {
                onSuccess()
            } label: {
                Text(String(localized: "Continue to Login"))
                    .font(.ftdLabelMD)
                    .foregroundStyle(Color.ftdAccentTeal)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignTokens.Spacing.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                            .stroke(Color.ftdAccentTeal, lineWidth: 1)
                    )
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        .padding(.vertical, DesignTokens.Spacing.xxl)
        .frame(maxWidth: .infinity, minHeight: 420)
        .background(Color.ftdCardBackground)
    }

    private var registrationIcon: some View {
        ZStack {
            Circle()
                .fill(Color.ftdAccentTeal.opacity(0.10))
                .frame(width: 110, height: 110)
            Circle()
                .fill(Color.ftdAccentTeal.opacity(0.18))
                .frame(width: 82, height: 82)
            Image(systemName: "hand.thumbsup")
                .font(.system(size: 34, weight: .medium))
                .foregroundStyle(Color.ftdAccentTeal)
        }
        .overlay(
            Circle().fill(Color.ftdAccentOrange).frame(width: 9, height: 9)
                .offset(x: 46, y: -30), alignment: .center
        )
        .overlay(
            Circle().fill(Color.ftdAccentOrange).frame(width: 6, height: 6)
                .offset(x: -50, y: -10), alignment: .center
        )
        .overlay(
            Circle().fill(Color.ftdAccentOrange.opacity(0.6)).frame(width: 7, height: 7)
                .offset(x: 38, y: 36), alignment: .center
        )
    }

    private var accountDetailsCard: some View {
        VStack(spacing: 0) {
            accountDetailRow(
                label: String(localized: "Agent ID:"),
                value: viewModel.registeredAgentNo ?? "—"
            )
            Divider().padding(.vertical, DesignTokens.Spacing.sm)
            accountDetailRow(
                label: String(localized: "Company Name:"),
                value: viewModel.companyName
            )
            Divider().padding(.vertical, DesignTokens.Spacing.sm)
            accountDetailRow(
                label: String(localized: "Agent Name:"),
                value: "\(viewModel.firstName) \(viewModel.lastName)"
            )
        }
        .padding(.vertical, DesignTokens.Spacing.md)
        .padding(.horizontal, DesignTokens.Spacing.md)
        .background(Color.ftdTextSecondary.opacity(0.04))
        .overlay(
            RoundedRectangle(cornerRadius: DesignTokens.Radius.field)
                .stroke(Color.ftdTextSecondary.opacity(0.18))
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
    }

    private func accountDetailRow(label: String, value: String) -> some View {
        HStack(alignment: .top, spacing: DesignTokens.Spacing.sm) {
            Text(label)
                .font(.caption)
                .foregroundStyle(Color.ftdTextSecondary)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
            Text(value.isEmpty ? "—" : value)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.ftdTextPrimary)
                .multilineTextAlignment(.trailing)
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private var documentsSection: some View {
        VStack(spacing: DesignTokens.Spacing.sm) {
            Text(String(localized: "Please provide the following documents ASAP for us to activate your account"))
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ftdTextPrimary)
                .multilineTextAlignment(.center)

            HStack(spacing: DesignTokens.Spacing.lg) {
                Label(String(localized: "PAN Card"), systemImage: "circle.fill")
                    .font(.subheadline)
                Label(String(localized: "Address Proof"), systemImage: "circle.fill")
                    .font(.subheadline)
            }
            .foregroundStyle(Color.ftdAccentTeal)
            .padding(.vertical, DesignTokens.Spacing.sm)
            .padding(.horizontal, DesignTokens.Spacing.md)
            .frame(maxWidth: .infinity)
            .background(Color.ftdTextSecondary.opacity(0.06))
            .clipShape(RoundedRectangle(cornerRadius: DesignTokens.Radius.field))
        }
    }

    // MARK: - Form View

    private var formView: some View {
        VStack(spacing: 0) {
            userTypeRow
                .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
                .padding(.top, DesignTokens.Spacing.xl)

            ScrollViewReader { proxy in
                VStack(spacing: Layout.fieldSpacing) {
                    personalInfoSection.id(SignUpViewModel.FormField.personal)
                    contactSection.id(SignUpViewModel.FormField.contact)
                    securitySection.id(SignUpViewModel.FormField.security)
                    complianceSection.id(SignUpViewModel.FormField.compliance)
                    businessSection.id(SignUpViewModel.FormField.business)
                    addressSection.id(SignUpViewModel.FormField.address)
                    apiErrorBanner
                    submitButton
                    termsDisclosure
                }
                .onChange(of: viewModel.scrollToken) { _, _ in
                    if let field = viewModel.scrollToField {
                        withAnimation { proxy.scrollTo(field, anchor: .top) }
                    }
                }
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
            .padding(.top, Layout.fieldSpacing)
            .padding(.bottom, DesignTokens.Spacing.screenBottom)
            .background(Color.ftdCardBackground)
        }
        .sheet(isPresented: $showTerms) {
            NavigationStack {
                TermsConditionView(viewModel: TermsConditionViewModel(authManager: authManager))
            }
        }
    }

    // MARK: - User Type Row

    private var userTypeRow: some View {
        @Bindable var vm = viewModel
        return HStack(alignment: .top, spacing: Layout.pairedSpacing) {
            FTDDropdownField(
                label: String(localized: "Choose User Type *"),//Choose User Type Select User Type
                placeholder: String(localized: "User Type"),
                selection: $vm.selectedUserType,
                options: UserType.allCases,
                optionLabel: { $0.displayName },
                optionIcon: { $0.systemImage }
            )
            FTDDropdownField(
                label: String(localized: "Title *"),
                placeholder: String(localized: "Title"),
                selection: $vm.selectedTitle,
                options: vm.titleOptions,
                optionLabel: { $0 }
            )
            .frame(maxWidth: Layout.titleFieldMaxWidth)
        }
    }

    // MARK: - Personal Info

    private var personalInfoSection: some View {
        @Bindable var vm = viewModel
        return HStack(alignment: .top, spacing: Layout.pairedSpacing) {
            FTDTextField(
                label: "",
                placeholder: String(localized: "First Name *"),
                text: $vm.firstName,
                errorMessage: vm.firstNameError
            )
            FTDTextField(
                label: "",
                placeholder: String(localized: "Last Name *"),
                text: $vm.lastName,
                errorMessage: vm.lastNameError
            )
        }
    }

    // MARK: - Contact

    private var contactSection: some View {
        @Bindable var vm = viewModel
        return VStack(spacing: Layout.fieldSpacing) {
            HStack(alignment: .top, spacing: Layout.pairedSpacing) {
                FTDTextField(
                    label: "",
                    placeholder: String(localized: "Mobile No *"),
                    text: $vm.mobile,
                    errorMessage: vm.mobileError,
                    keyboardType: .phonePad
                )
                FTDTextField(
                    label: "",
                    placeholder: String(localized: "Landline No"),
                    text: $vm.landline,
                    keyboardType: .phonePad
                )
            }
            FTDTextField(
                label: "",
                placeholder: String(localized: "Email *"),
                text: $vm.email,
                errorMessage: vm.emailError,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            FTDTextField(
                label: "",
                placeholder: String(localized: "Website"),
                text: $vm.website,
                keyboardType: .URL,
                autocapitalization: .never
            )
            FTDTextField(
                label: "",
                placeholder: String(localized: "Designation"),
                text: $vm.designation
            )
        }
    }

    // MARK: - Security

    private var securitySection: some View {
        @Bindable var vm = viewModel
        return HStack(alignment: .top, spacing: Layout.pairedSpacing) {
            FTDSecureField(
                label: String(localized: "Password *"),
                placeholder: "✻ ✻ ✻ ✻ ✻ ✻ ✻ ✻",
                text: $vm.password,
                isVisible: $vm.showPassword,
                errorMessage: vm.passwordError
            )
            FTDSecureField(
                label: String(localized: "Confirm Password *"),
                placeholder: "✻ ✻ ✻ ✻ ✻ ✻ ✻ ✻",
                text: $vm.confirmPassword,
                isVisible: $vm.showConfirmPassword,
                errorMessage: vm.confirmPasswordError
            )
        }
    }

    // MARK: - Compliance

    private var complianceSection: some View {
        @Bindable var vm = viewModel
        return VStack(spacing: Layout.fieldSpacing) {
            FTDTextField(
                label: "",
                placeholder: String(localized: "PAN No *"),
                text: $vm.panNumber,
                errorMessage: vm.panNumberError,
                autocapitalization: .characters
            )
            FTDTextField(
                label: "",
                placeholder: String(localized: "Name on PAN Card *"),
                text: $vm.panCardName,
                errorMessage: vm.panCardNameError
            )
            FTDTextField(
                label: "",
                placeholder: String(localized: "ID Card Number"),
                text: $vm.idCardNumber
            )
        }
    }

    // MARK: - Business

    private var businessSection: some View {
        @Bindable var vm = viewModel
        return VStack(spacing: Layout.fieldSpacing) {
            FTDTextField(
                label: "",
                placeholder: String(localized: "Company Name *"),
                text: $vm.companyName,
                errorMessage: vm.companyNameError
            )
            FTDTextField(
                label: "",
                placeholder: String(localized: "GST No"),
                text: $vm.gstNumber,
                autocapitalization: .characters
            )
        }
    }

    // MARK: - Address

    private var addressSection: some View {
        @Bindable var vm = viewModel
        return VStack(spacing: Layout.fieldSpacing) {
            FTDTextField(
                label: "",
                placeholder: String(localized: "Address *"),
                text: $vm.address,
                errorMessage: vm.addressError
            )
            HStack(alignment: .top, spacing: Layout.pairedSpacing) {
                FTDTextField(
                    label: "",
                    placeholder: String(localized: "Pin Code *"),
                    text: $vm.pinCode,
                    errorMessage: vm.pinCodeError,
                    keyboardType: .numberPad
                )
                FTDTextField(
                    label: "",
                    placeholder: String(localized: "City *"),
                    text: $vm.city,
                    errorMessage: vm.cityError
                )
            }
            HStack(alignment: .top, spacing: Layout.pairedSpacing) {
                stateField
                countryField
            }
        }
    }

    // State: dropdown when selected country has states, free-text otherwise
    @ViewBuilder
    private var stateField: some View {
        @Bindable var vm = viewModel
        if vm.hasStateOptions {
            FTDDropdownField(
                label: String(localized: "State *"),
                placeholder: String(localized: ""),
                selection: $vm.selectedState,
                options: vm.stateOptions,
                optionLabel: { $0 },
                errorMessage: vm.stateError
            )
        } else {
            FTDTextField(
                label: "",
                placeholder: String(localized: "State *"),
                text: $vm.selectedState,
                errorMessage: vm.stateError
            )
        }
    }

    // Country: loaded from API, with loading indicator
    private var countryField: some View {
        @Bindable var vm = viewModel
        return FTDDropdownField(
            label: vm.isLoadingCountries
                ? String(localized: "Country")
                : String(localized: "Country *"),
            placeholder: vm.isLoadingCountries
                ? String(localized: "Loading...")
                : String(localized: "Country"),
            selection: $vm.selectedCountry,
            options: vm.countries,
            optionLabel: { $0.name },
            errorMessage: vm.countryError
        )
        .disabled(vm.isLoadingCountries)
    }

    // MARK: - Terms Disclosure

    private var termsDisclosure: some View {
        VStack(spacing: DesignTokens.Spacing.xxs) {
            Text(String(localized: "By clicking on the Sign Up button, I agree to the"))
                .font(.ftdPlaceholder)
                .foregroundStyle(Color.ftdTextSecondary)
            Button {
                showTerms = true
            } label: {
                Text(String(localized: "Terms & Condition"))
                    .font(.ftdLabelSM)
                    .foregroundStyle(Color.ftdAccentTeal)
            }
            .buttonStyle(.plain)
        }
        .multilineTextAlignment(.center)
    }

    // MARK: - API Error + Submit

    @ViewBuilder
    private var apiErrorBanner: some View {
        if let error = viewModel.apiError {
            Text(error)
                .font(.subheadline)
                .foregroundStyle(Color.ftdDestructiveRed)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .padding(.vertical, Layout.errorVerticalPadding)
                .padding(.horizontal, Layout.errorHorizontalPadding)
                .background(Color.ftdDestructiveRed.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: Layout.errorCornerRadius))
        }
    }

    private var submitButton: some View {
        FTDPrimaryButton(
            title: String(localized: "Sign Up"),
            isLoading: viewModel.isSubmitting
        ) {
            Task { await viewModel.submit() }
        }
    }
}
