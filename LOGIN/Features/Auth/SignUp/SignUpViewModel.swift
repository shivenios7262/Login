import Foundation
import Observation

@Observable
@MainActor
final class SignUpViewModel {
    // Personal
    var selectedUserType: UserType = .travelAgent
    var selectedTitle: String = "Mr"
    var firstName: String = "" { didSet { firstNameError = nil } }
    var lastName: String = ""  { didSet { lastNameError = nil } }
    var mobile: String = ""    { didSet { mobileError = nil } }
    var landline: String = ""
    var email: String = ""     { didSet { emailError = nil } }
    var website: String = ""
    var designation: String = ""

    // Security
    var password: String = ""        { didSet { passwordError = nil } }
    var confirmPassword: String = "" { didSet { confirmPasswordError = nil } }
    var showPassword: Bool = false
    var showConfirmPassword: Bool = false

    // Compliance
    var panNumber: String = ""   { didSet { panNumberError = nil } }
    var panCardName: String = "" { didSet { panCardNameError = nil } }
    var idCardNumber: String = ""
    var companyName: String = "" { didSet { companyNameError = nil } }
    var gstNumber: String = ""

    // Address
    var address: String = ""        { didSet { addressError = nil } }
    var pinCode: String = ""        { didSet { pinCodeError = nil } }
    var city: String = ""           { didSet { cityError = nil } }
    var selectedState: String = ""  { didSet { stateError = nil } }
    var selectedCountry: String = "" { didSet { countryError = nil } }

    // Agreements
    var isCaptchaChecked: Bool = false { didSet { if isCaptchaChecked { captchaError = nil } } }
    var isTermsAccepted: Bool = false  { didSet { if isTermsAccepted  { termsError = nil  } } }

    // Submission state
    private(set) var isSubmitting: Bool = false

    // Field errors
    var firstNameError: String?
    var lastNameError: String?
    var mobileError: String?
    var emailError: String?
    var passwordError: String?
    var confirmPasswordError: String?
    var panNumberError: String?
    var panCardNameError: String?
    var companyNameError: String?
    var addressError: String?
    var pinCodeError: String?
    var cityError: String?
    var stateError: String?
    var countryError: String?
    var captchaError: String?
    var termsError: String?

    // MARK: - Option Lists

    let titleOptions: [String] = ["Mr", "Mrs", "Ms", "Dr"]

    let stateOptions: [String] = [
        "Andhra Pradesh", "Arunachal Pradesh", "Assam", "Bihar", "Chhattisgarh",
        "Goa", "Gujarat", "Haryana", "Himachal Pradesh", "Jharkhand",
        "Karnataka", "Kerala", "Madhya Pradesh", "Maharashtra", "Manipur",
        "Meghalaya", "Mizoram", "Nagaland", "Odisha", "Punjab",
        "Rajasthan", "Sikkim", "Tamil Nadu", "Telangana", "Tripura",
        "Uttar Pradesh", "Uttarakhand", "West Bengal",
        "Delhi", "Jammu & Kashmir", "Ladakh", "Puducherry"
    ]

    let countryOptions: [String] = [
        "India", "United States", "United Kingdom", "UAE", "Singapore",
        "Australia", "Canada", "Germany", "France", "Japan", "Other"
    ]

    // MARK: - Actions

    func submit() async {
        guard validate() else { return }
        isSubmitting = true
        defer { isSubmitting = false }
        // TODO: wire to sign-up API endpoint once available
    }

    // MARK: - Validation

    private func validate() -> Bool {
        clearErrors()
        var valid = true

        if firstName.trimmingCharacters(in: .whitespaces).isEmpty {
            firstNameError = String(localized: "First name is required")
            valid = false
        }
        if lastName.trimmingCharacters(in: .whitespaces).isEmpty {
            lastNameError = String(localized: "Last name is required")
            valid = false
        }
        let trimmedMobile = mobile.trimmingCharacters(in: .whitespaces)
        if trimmedMobile.isEmpty {
            mobileError = String(localized: "Mobile number is required")
            valid = false
        } else if trimmedMobile.count != 10 || !trimmedMobile.allSatisfy(\.isNumber) {
            mobileError = String(localized: "Enter a valid 10-digit mobile number")
            valid = false
        }
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        if trimmedEmail.isEmpty {
            emailError = String(localized: "Email is required")
            valid = false
        } else if !isValidEmail(trimmedEmail) {
            emailError = String(localized: "Enter a valid email address")
            valid = false
        }
        if password.isEmpty {
            passwordError = String(localized: "Password is required")
            valid = false
        } else if password.count < 8 {
            passwordError = String(localized: "Password must be at least 8 characters")
            valid = false
        }
        if confirmPassword.isEmpty {
            confirmPasswordError = String(localized: "Please confirm your password")
            valid = false
        } else if password != confirmPassword {
            confirmPasswordError = String(localized: "Passwords do not match")
            valid = false
        }
        let trimmedPAN = panNumber.trimmingCharacters(in: .whitespaces)
        if trimmedPAN.isEmpty {
            panNumberError = String(localized: "PAN number is required")
            valid = false
        } else if !isValidPAN(trimmedPAN) {
            panNumberError = String(localized: "Enter a valid PAN number (e.g. ABCDE1234F)")
            valid = false
        }
        if panCardName.trimmingCharacters(in: .whitespaces).isEmpty {
            panCardNameError = String(localized: "Name on PAN card is required")
            valid = false
        }
        if companyName.trimmingCharacters(in: .whitespaces).isEmpty {
            companyNameError = String(localized: "Company name is required")
            valid = false
        }
        if address.trimmingCharacters(in: .whitespaces).isEmpty {
            addressError = String(localized: "Address is required")
            valid = false
        }
        let trimmedPin = pinCode.trimmingCharacters(in: .whitespaces)
        if trimmedPin.isEmpty {
            pinCodeError = String(localized: "Pin code is required")
            valid = false
        } else if trimmedPin.count != 6 || !trimmedPin.allSatisfy(\.isNumber) {
            pinCodeError = String(localized: "Enter a valid 6-digit pin code")
            valid = false
        }
        if city.trimmingCharacters(in: .whitespaces).isEmpty {
            cityError = String(localized: "City is required")
            valid = false
        }
        if selectedState.isEmpty {
            stateError = String(localized: "Please select a state")
            valid = false
        }
        if selectedCountry.isEmpty {
            countryError = String(localized: "Please select a country")
            valid = false
        }
        if !isCaptchaChecked {
            captchaError = String(localized: "Please verify you are not a robot")
            valid = false
        }
        if !isTermsAccepted {
            termsError = String(localized: "Please accept the terms and conditions")
            valid = false
        }

        return valid
    }

    private func clearErrors() {
        firstNameError = nil;  lastNameError = nil;   mobileError = nil
        emailError = nil;      passwordError = nil;   confirmPasswordError = nil
        panNumberError = nil;  panCardNameError = nil; companyNameError = nil
        addressError = nil;    pinCodeError = nil;    cityError = nil
        stateError = nil;      countryError = nil
        captchaError = nil;    termsError = nil
    }

    private func isValidEmail(_ value: String) -> Bool {
        let regex = /^[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}$/
        return value.uppercased().wholeMatch(of: regex) != nil
    }

    private func isValidPAN(_ value: String) -> Bool {
        let regex = /^[A-Z]{5}[0-9]{4}[A-Z]{1}$/
        return value.uppercased().wholeMatch(of: regex) != nil
    }
}
