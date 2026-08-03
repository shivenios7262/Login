import Foundation
import Observation

@Observable
@MainActor
final class SignUpViewModel {

    // MARK: - Personal
    var selectedUserType: UserType = .travelAgent
    var selectedTitle: String = "Mr"
    var firstName: String = ""  { didSet { firstNameError    = nil } }
    var lastName: String = ""   { didSet { lastNameError     = nil } }
    var mobile: String = ""     { didSet { mobileError       = nil } }
    var landline: String = ""
    var email: String = ""      { didSet { emailError        = nil } }
    var website: String = ""
    var designation: String = ""

    // MARK: - Security
    var password: String = ""        { didSet { passwordError        = nil } }
    var confirmPassword: String = "" { didSet { confirmPasswordError = nil } }
    var showPassword: Bool = false
    var showConfirmPassword: Bool = false

    // MARK: - Compliance
    var panNumber: String = ""   { didSet { panNumberError   = nil } }
    var panCardName: String = "" { didSet { panCardNameError = nil } }
    var idCardNumber: String = ""
    var companyName: String = "" { didSet { companyNameError = nil } }
    var gstNumber: String = ""

    // MARK: - Address
    var address: String = ""         { didSet { addressError  = nil } }
    var pinCode: String = ""         { didSet { pinCodeError  = nil } }
    var city: String = ""            { didSet { cityError     = nil } }
    var selectedState: String = ""   { didSet { stateError    = nil } }
    var selectedCountry: String = "" { didSet { countryError  = nil } }


    // MARK: - Submission state
    private(set) var isSubmitting: Bool = false
    private(set) var apiError: String?

    // MARK: - Field errors
    private(set) var firstNameError: String?
    private(set) var lastNameError: String?
    private(set) var mobileError: String?
    private(set) var emailError: String?
    private(set) var passwordError: String?
    private(set) var confirmPasswordError: String?
    private(set) var panNumberError: String?
    private(set) var panCardNameError: String?
    private(set) var companyNameError: String?
    private(set) var addressError: String?
    private(set) var pinCodeError: String?
    private(set) var cityError: String?
    private(set) var stateError: String?
    private(set) var countryError: String?

    // MARK: - Option lists

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

    // MARK: - Dependencies

    private let authManager: AuthManager
    private let onSuccess: () -> Void

    init(authManager: AuthManager, onSuccess: @escaping () -> Void) {
        self.authManager = authManager
        self.onSuccess   = onSuccess
    }

    // MARK: - Submit

    func submit() async {
        guard validate() else { return }
        isSubmitting = true
        apiError = nil
        defer { isSubmitting = false }

        let request = AgentRegisterRequest(
            agentType:       selectedUserType.apiValue,
            title:           selectedTitle,
            firstName:       firstName.trimmed,
            lastName:        lastName.trimmed,
            mobileNo:        mobile.trimmed,
            officePhoneNo:   landline.trimmedOrNil,
            agentEmail:      email.trimmed,
            website:         website.trimmedOrNil,
            designation:     designation.trimmedOrNil,
            agentPassword:   password,
            confirmPassword: confirmPassword,
            panNo:           panNumber.trimmedOrNil,
            namePanCard:     panCardName.trimmedOrNil,
            aadharNo:        idCardNumber.trimmedOrNil,
            agencyName:      companyName.trimmed,
            serviceTaxNo:    gstNumber.trimmedOrNil,
            address:         address.trimmed,
            pinCode:         pinCode.trimmed,
            city:            city.trimmed,
            state:           selectedState,
            country:         selectedCountry
        )

        do {
            try await authManager.register(request: request)
            onSuccess()
        } catch let error as NetworkError {
            apiError = error.errorDescription
        } catch {
            apiError = error.localizedDescription
        }
    }

    // MARK: - Validation

    private func validate() -> Bool {
        clearErrors()
        var valid = true

        func check(_ result: String?, assign: (String?) -> Void) {
            if result != nil { assign(result); valid = false }
        }

        check(Validator.requiredText(firstName, fieldName: "First name")) { firstNameError = $0 }
        check(Validator.requiredText(lastName,  fieldName: "Last name"))  { lastNameError  = $0 }
        check(Validator.phone(mobile))   { mobileError   = $0 }
        check(Validator.email(email))    { emailError    = $0 }
        check(Validator.password(password)) { passwordError = $0 }
        check(Validator.confirmPassword(confirmPassword, matching: password)) { confirmPasswordError = $0 }
        check(Validator.pan(panNumber))  { panNumberError = $0 }
        check(Validator.requiredText(panCardName,  fieldName: "Name on PAN card")) { panCardNameError  = $0 }
        check(Validator.requiredText(companyName,  fieldName: "Company name"))     { companyNameError  = $0 }
        check(Validator.requiredText(address,      fieldName: "Address"))          { addressError      = $0 }
        check(Validator.pinCode(pinCode)) { pinCodeError = $0 }
        check(Validator.requiredText(city,          fieldName: "City"))            { cityError         = $0 }

        if selectedState.isEmpty   { stateError   = String(localized: "Please select a state");   valid = false }
        if selectedCountry.isEmpty { countryError = String(localized: "Please select a country"); valid = false }

        return valid
    }

    private func clearErrors() {
        firstNameError = nil;   lastNameError = nil;      mobileError = nil
        emailError = nil;       passwordError = nil;      confirmPasswordError = nil
        panNumberError = nil;   panCardNameError = nil;   companyNameError = nil
        addressError = nil;     pinCodeError = nil;       cityError = nil
        stateError = nil;       countryError = nil
        apiError = nil
    }
}

// MARK: - String Helpers

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespaces) }
    var trimmedOrNil: String? { trimmed.isEmpty ? nil : trimmed }
}
