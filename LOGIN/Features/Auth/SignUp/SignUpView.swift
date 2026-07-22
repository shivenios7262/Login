import SwiftUI

struct SignUpView: View {
    @State private var viewModel = SignUpViewModel()

    var body: some View {
        VStack(spacing: 20) {
            // User Type + Title
            HStack(alignment: .top, spacing: 12) {
                FTDDropdownField(
                    label: String(localized: "Select User Type *"),
                    placeholder: String(localized: "User Type"),
                    selection: $viewModel.selectedUserType,
                    options: UserType.allCases,
                    optionLabel: { $0.displayName }
                )
                FTDDropdownField(
                    label: String(localized: "Title *"),
                    placeholder: String(localized: "Title"),
                    selection: $viewModel.selectedTitle,
                    options: viewModel.titleOptions,
                    optionLabel: { $0 }
                )
                .frame(maxWidth: 100)
            }

            // Name
            HStack(alignment: .top, spacing: 12) {
                FTDTextField(
                    label: String(localized: "First Name *"),
                    placeholder: String(localized: "First Name"),
                    text: $viewModel.firstName,
                    errorMessage: viewModel.firstNameError
                )
                FTDTextField(
                    label: String(localized: "Last Name *"),
                    placeholder: String(localized: "Last Name"),
                    text: $viewModel.lastName,
                    errorMessage: viewModel.lastNameError
                )
            }

            // Phone
            HStack(alignment: .top, spacing: 12) {
                FTDTextField(
                    label: String(localized: "Mobile No *"),
                    placeholder: String(localized: "Mobile No"),
                    text: $viewModel.mobile,
                    errorMessage: viewModel.mobileError,
                    keyboardType: .phonePad
                )
                FTDTextField(
                    label: String(localized: "Landline No"),
                    placeholder: String(localized: "Landline No"),
                    text: $viewModel.landline,
                    keyboardType: .phonePad
                )
            }

            FTDTextField(
                label: String(localized: "Email *"),
                placeholder: String(localized: "Email"),
                text: $viewModel.email,
                errorMessage: viewModel.emailError,
                keyboardType: .emailAddress,
                autocapitalization: .never
            )

            FTDTextField(
                label: String(localized: "Website"),
                placeholder: String(localized: "Website"),
                text: $viewModel.website,
                keyboardType: .URL,
                autocapitalization: .never
            )

            FTDTextField(
                label: String(localized: "Designation"),
                placeholder: String(localized: "Designation"),
                text: $viewModel.designation
            )

            // Password pair
            HStack(alignment: .top, spacing: 12) {
                FTDSecureField(
                    label: String(localized: "Password *"),
                    placeholder: String(localized: "Password"),
                    text: $viewModel.password,
                    isVisible: $viewModel.showPassword,
                    errorMessage: viewModel.passwordError
                )
                FTDSecureField(
                    label: String(localized: "Confirm Password *"),
                    placeholder: String(localized: "Confirm Password"),
                    text: $viewModel.confirmPassword,
                    isVisible: $viewModel.showConfirmPassword,
                    errorMessage: viewModel.confirmPasswordError
                )
            }

            FTDTextField(
                label: String(localized: "PAN No *"),
                placeholder: String(localized: "PAN No"),
                text: $viewModel.panNumber,
                errorMessage: viewModel.panNumberError,
                autocapitalization: .characters
            )

            FTDTextField(
                label: String(localized: "Name on PAN Card *"),
                placeholder: String(localized: "Name on PAN Card"),
                text: $viewModel.panCardName,
                errorMessage: viewModel.panCardNameError
            )

            FTDTextField(
                label: String(localized: "ID Card Number"),
                placeholder: String(localized: "ID Card Number"),
                text: $viewModel.idCardNumber
            )

            FTDTextField(
                label: String(localized: "Company Name *"),
                placeholder: String(localized: "Company Name"),
                text: $viewModel.companyName,
                errorMessage: viewModel.companyNameError
            )

            FTDTextField(
                label: String(localized: "GST No"),
                placeholder: String(localized: "GST No"),
                text: $viewModel.gstNumber,
                autocapitalization: .characters
            )

            FTDTextField(
                label: String(localized: "Address *"),
                placeholder: String(localized: "Address"),
                text: $viewModel.address,
                errorMessage: viewModel.addressError
            )

            // Pin Code + City
            HStack(alignment: .top, spacing: 12) {
                FTDTextField(
                    label: String(localized: "Pin Code *"),
                    placeholder: String(localized: "Pin Code"),
                    text: $viewModel.pinCode,
                    errorMessage: viewModel.pinCodeError,
                    keyboardType: .numberPad
                )
                FTDTextField(
                    label: String(localized: "City *"),
                    placeholder: String(localized: "City"),
                    text: $viewModel.city,
                    errorMessage: viewModel.cityError
                )
            }

            // State + Country
            HStack(alignment: .top, spacing: 12) {
                FTDDropdownField(
                    label: String(localized: "State *"),
                    placeholder: String(localized: "State"),
                    selection: $viewModel.selectedState,
                    options: viewModel.stateOptions,
                    optionLabel: { $0 }
                )
                FTDDropdownField(
                    label: String(localized: "Country *"),
                    placeholder: String(localized: "Country"),
                    selection: $viewModel.selectedCountry,
                    options: viewModel.countryOptions,
                    optionLabel: { $0 }
                )
            }

            // Captcha
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 10) {
                    Toggle(isOn: $viewModel.isCaptchaChecked) {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.shield")
                                .foregroundStyle(Color("TextSecondary"))
                            Text("I'm not a robot")
                                .foregroundStyle(Color("TextPrimary"))
                        }
                    }
                    .toggleStyle(.checkboxStyle)
                }
                if let err = viewModel.captchaError {
                    Text(err)
                        .font(.caption)
                        .foregroundStyle(Color("DestructiveRed"))
                }
            }

            // Terms
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .top, spacing: 10) {
                    Toggle(isOn: $viewModel.isTermsAccepted) { EmptyView() }
                        .toggleStyle(.checkboxStyle)
                        .frame(width: 24)
                    // Inline T&C text with link
                    (
                        Text("By clicking the Sign Up button, I agree to the ")
                            .foregroundStyle(Color("TextSecondary"))
                        + Text("Terms & Conditions")
                            .foregroundStyle(Color("AccentOrange"))
                    )
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                }
                if let err = viewModel.termsError {
                    Text(err)
                        .font(.caption)
                        .foregroundStyle(Color("DestructiveRed"))
                }
            }

            FTDPrimaryButton(
                title: String(localized: "Sign Up"),
                isLoading: viewModel.isSubmitting
            ) {
                Task { await viewModel.submit() }
            }
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 36)
    }
}

// MARK: - Checkbox Toggle Style

private struct CheckboxToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Image(systemName: configuration.isOn ? "checkmark.square.fill" : "square")
                    .foregroundStyle(
                        configuration.isOn ? Color("AccentOrange") : Color("BorderColor")
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
