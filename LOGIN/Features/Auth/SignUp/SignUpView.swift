import SwiftUI

struct SignUpView: View {
    private let authManager: AuthManager
    @State private var viewModel: SignUpViewModel

    private enum Layout {
        static let fieldSpacing: CGFloat       = DesignTokens.Spacing.fieldSpacing
        static let pairedSpacing: CGFloat      = DesignTokens.Spacing.md
        static let titleFieldMaxWidth: CGFloat = 100
        static let errorCornerRadius: CGFloat  = DesignTokens.Radius.field
        static let errorVerticalPadding: CGFloat   = DesignTokens.Spacing.inputVertical
        static let errorHorizontalPadding: CGFloat = DesignTokens.Spacing.inputHorizontal
    }

    init(authManager: AuthManager, onSuccess: @escaping () -> Void) {
        self.authManager = authManager
        _viewModel = State(initialValue: SignUpViewModel(authManager: authManager, onSuccess: onSuccess))
    }

    var body: some View {
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
                agreementsSection
                apiErrorBanner
                submitButton
            }
            .padding(.horizontal, DesignTokens.Spacing.screenHorizontal)
            .padding(.top, Layout.fieldSpacing)
            .padding(.bottom, DesignTokens.Spacing.screenBottom)
            .background(Color.ftdCardBackground)
        }
    }

    // MARK: - User Type Row (transparent — dotted map shows through)

    private var userTypeRow: some View {
        @Bindable var vm = viewModel
        return HStack(alignment: .top, spacing: Layout.pairedSpacing) {
            FTDDropdownField(
                label: String(localized: "Select User Type *"),
                placeholder: String(localized: "User Type"),
                selection: $vm.selectedUserType,
                options: UserType.allCases,
                optionLabel: { $0.displayName }
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
                label: String(localized: "First Name *"),
                placeholder: String(localized: "First Name"),
                text: $vm.firstName,
                errorMessage: vm.firstNameError
            )
            FTDTextField(
                label: String(localized: "Last Name *"),
                placeholder: String(localized: "Last Name"),
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
                    label: String(localized: "Mobile No *"),
                    placeholder: String(localized: "Mobile No"),
                    text: $vm.mobile,
                    errorMessage: vm.mobileError,
                    keyboardType: .phonePad
                )
                FTDTextField(
                    label: String(localized: "Landline No"),
                    placeholder: String(localized: "Landline No"),
                    text: $vm.landline,
                    keyboardType: .phonePad
                )
            }
            FTDTextField(
                label: String(localized: "Email *"),
                placeholder: String(localized: "Email"),
                text: $vm.email,
                errorMessage: vm.emailError,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )
            FTDTextField(
                label: String(localized: "Website"),
                placeholder: String(localized: "Website"),
                text: $vm.website,
                keyboardType: .URL,
                autocapitalization: .never
            )
            FTDTextField(
                label: String(localized: "Designation"),
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
                placeholder: String(localized: "Password"),
                text: $vm.password,
                isVisible: $vm.showPassword,
                errorMessage: vm.passwordError
            )
            FTDSecureField(
                label: String(localized: "Confirm Password *"),
                placeholder: String(localized: "Confirm Password"),
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
                label: String(localized: "PAN No *"),
                placeholder: String(localized: "PAN No"),
                text: $vm.panNumber,
                errorMessage: vm.panNumberError,
                autocapitalization: .characters
            )
            FTDTextField(
                label: String(localized: "Name on PAN Card *"),
                placeholder: String(localized: "Name on PAN Card"),
                text: $vm.panCardName,
                errorMessage: vm.panCardNameError
            )
            FTDTextField(
                label: String(localized: "ID Card Number"),
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
                label: String(localized: "Company Name *"),
                placeholder: String(localized: "Company Name"),
                text: $vm.companyName,
                errorMessage: vm.companyNameError
            )
            FTDTextField(
                label: String(localized: "GST No"),
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
                label: String(localized: "Address *"),
                placeholder: String(localized: "Address"),
                text: $vm.address,
                errorMessage: vm.addressError
            )
            HStack(alignment: .top, spacing: Layout.pairedSpacing) {
                FTDTextField(
                    label: String(localized: "Pin Code *"),
                    placeholder: String(localized: "Pin Code"),
                    text: $vm.pinCode,
                    errorMessage: vm.pinCodeError,
                    keyboardType: .numberPad
                )
                FTDTextField(
                    label: String(localized: "City *"),
                    placeholder: String(localized: "City"),
                    text: $vm.city,
                    errorMessage: vm.cityError
                )
            }
            HStack(alignment: .top, spacing: Layout.pairedSpacing) {
                FTDDropdownField(
                    label: String(localized: "State *"),
                    placeholder: String(localized: "State"),
                    selection: $vm.selectedState,
                    options: vm.stateOptions,
                    optionLabel: { $0 },
                    errorMessage: vm.stateError
                )
                FTDDropdownField(
                    label: String(localized: "Country *"),
                    placeholder: String(localized: "Country"),
                    selection: $vm.selectedCountry,
                    options: vm.countryOptions,
                    optionLabel: { $0 },
                    errorMessage: vm.countryError
                )
            }
        }
    }

    // MARK: - Agreements

    private var agreementsSection: some View {
        VStack(alignment: .leading, spacing: Layout.fieldSpacing) {
            captchaRow
            termsRow
        }
    }

    private var captchaRow: some View {
        @Bindable var vm = viewModel
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            Toggle(isOn: $vm.isCaptchaChecked) {
                HStack(spacing: DesignTokens.Spacing.sm - 2) {
                    Image(systemName: "checkmark.shield")
                        .foregroundStyle(Color.ftdTextSecondary)
                    Text(String(localized: "I'm not a robot"))
                        .foregroundStyle(Color.ftdTextPrimary)
                }
            }
            .toggleStyle(.checkboxStyle)
            if let err = viewModel.captchaError {
                Text(err).font(.caption).foregroundStyle(Color.ftdDestructiveRed)
            }
        }
    }

    private var termsRow: some View {
        @Bindable var vm = viewModel
        return VStack(alignment: .leading, spacing: DesignTokens.Spacing.xs) {
            HStack(alignment: .top, spacing: DesignTokens.Spacing.inputVertical) {
                Toggle(isOn: $vm.isTermsAccepted) { EmptyView() }
                    .toggleStyle(.checkboxStyle)
                    .frame(width: 24)
                (
                    Text("By clicking the Sign Up button, I agree to the ")
                        .foregroundStyle(Color.ftdTextSecondary)
                    + Text("Terms & Conditions")
                        .foregroundStyle(Color.ftdAccentOrange)
                )
                .font(.caption)
                .multilineTextAlignment(.leading)
            }
            if let err = viewModel.termsError {
                Text(err).font(.caption).foregroundStyle(Color.ftdDestructiveRed)
            }
        }
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

// MARK: - Checkbox Toggle Style

private struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: DesignTokens.Spacing.sm) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundStyle(
                        configuration.isOn ? Color.ftdAccentOrange : Color.ftdBorder
                    )
                    .font(.system(size: 20))
                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}

extension ToggleStyle where Self == CheckboxToggleStyle {
    static var checkboxStyle: CheckboxToggleStyle { CheckboxToggleStyle() }
}
