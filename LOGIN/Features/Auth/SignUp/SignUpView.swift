import SwiftUI

struct SignUpView: View {
    private let onSuccess: () -> Void
    @State private var viewModel: SignUpViewModel

    private enum Layout {
        static let fieldSpacing: CGFloat           = DesignTokens.Spacing.fieldSpacing
        static let pairedSpacing: CGFloat          = DesignTokens.Spacing.md
        static let titleFieldMaxWidth: CGFloat     = 100
        static let errorCornerRadius: CGFloat      = DesignTokens.Radius.field
        static let errorVerticalPadding: CGFloat   = DesignTokens.Spacing.inputVertical
        static let errorHorizontalPadding: CGFloat = DesignTokens.Spacing.inputHorizontal
    }

    init(authManager: AuthManager, onSuccess: @escaping () -> Void) {
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
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 80))
                .foregroundStyle(Color.ftdAccentOrange)

            VStack(spacing: DesignTokens.Spacing.sm) {
                Text(String(localized: "Registration Submitted!"))
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.ftdTextPrimary)
                    .multilineTextAlignment(.center)

                Text(String(localized: "Thank you for registering with FTD Travel. Your application is under review. We'll notify you once your account is approved."))
                    .font(.subheadline)
                    .foregroundStyle(Color.ftdTextSecondary)
                    .multilineTextAlignment(.center)
            }

            FTDPrimaryButton(
                title: String(localized: "Continue to Login"),
                isLoading: false
            ) {
                onSuccess()
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
        .padding(.vertical, DesignTokens.Spacing.xxl)
        .frame(maxWidth: .infinity, minHeight: 420)
        .background(Color.ftdCardBackground)
    }

    // MARK: - Form View

    private var formView: some View {
        VStack(spacing: 0) {
            userTypeRow
                .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
                .padding(.top, DesignTokens.Spacing.xl)

            VStack(spacing: Layout.fieldSpacing) {
                personalInfoSection
                contactSection
                securitySection
                complianceSection
                businessSection
                addressSection
                apiErrorBanner
                submitButton
                termsDisclosure
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
            .padding(.top, Layout.fieldSpacing)
            .padding(.bottom, DesignTokens.Spacing.screenBottom)
            .background(Color.ftdCardBackground)
        }
    }

    // MARK: - User Type Row

    private var userTypeRow: some View {
        @Bindable var vm = viewModel
        return HStack(alignment: .top, spacing: Layout.pairedSpacing) {
            FTDDropdownField(
                label: String(localized: "Select User Type *"),
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
                placeholder: "••••••••",
                text: $vm.password,
                isVisible: $vm.showPassword,
                errorMessage: vm.passwordError
            )
            FTDSecureField(
                label: String(localized: "Confirm Password *"),
                placeholder: "••••••••",
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
                placeholder: String(localized: "State"),
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
                .font(.caption)
                .foregroundStyle(Color.ftdTextSecondary)
            Text(String(localized: "Terms & Condition"))
                .font(.caption)
                .foregroundStyle(Color.ftdAccentTeal)
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
