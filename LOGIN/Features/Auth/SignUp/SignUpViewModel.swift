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
    var address: String = ""  { didSet { addressError = nil } }
    var pinCode: String = ""  { didSet { pinCodeError  = nil } }
    var city: String = ""     { didSet { cityError     = nil } }

    var selectedCountry: CountryItem = .unselected {
        didSet {
            selectedState = ""
            stateError    = nil
            countryError  = nil
        }
    }
    var selectedState: String = "" { didSet { stateError = nil } }

    // MARK: - Country / State options (from API)

    var countries: [CountryItem] = []
    var isLoadingCountries: Bool = false

    // Derived from selected country — if non-empty, show dropdown; otherwise free-text
    var stateOptions: [String] {
        selectedCountry.states
            .sorted {
                let isTrailing: (String) -> Bool = {
                    let l = $0.lowercased()
                    return l.hasPrefix("other") || l.hasPrefix("outside")
                }
                let lTrail = isTrailing($0.name)
                let rTrail = isTrailing($1.name)
                if lTrail != rTrail { return !lTrail }
                return $0.name < $1.name
            }
            .map(\.name)
    }
    var hasStateOptions: Bool  { !selectedCountry.states.isEmpty }

    // MARK: - Submission state
    private(set) var isSubmitting: Bool = false
    private(set) var isRegistered: Bool = false
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

    // MARK: - Static options
    let titleOptions: [String] = ["Mr", "Mrs", "Ms", "Dr"]

    // MARK: - Dependencies
    private let authManager: AuthManager

    init(authManager: AuthManager) {
        self.authManager = authManager
        Task { await loadCountries() }
    }

    // MARK: - Load Countries

    func loadCountries() async {
        isLoadingCountries = true
        defer { isLoadingCountries = false }
        do {
            let raw = try await authManager.fetchCountries()
            countries = raw.sorted {
                let lIndia = $0.iso2.uppercased() == "IN"
                let rIndia = $1.iso2.uppercased() == "IN"
                let lOther = $0.name.lowercased().hasPrefix("other")
                let rOther = $1.name.lowercased().hasPrefix("other")
                if lIndia != rIndia { return lIndia }
                if lOther != rOther { return !lOther }
                return $0.name < $1.name
            }
            if selectedCountry == .unselected,
               let india = countries.first(where: { $0.iso2.uppercased() == "IN" }) {
                selectedCountry = india
            }
        } catch {
            // Non-fatal: picker remains empty; user can retry via the retry button
        }
    }

    // MARK: - Submit

    func submit() async {
        guard validate() else { return }
        isSubmitting = true
        apiError = nil
        defer { isSubmitting = false }

        // Password equality is verified in validate() before building the request
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
            country:         selectedCountry.name,
            adCampaign:      "Mobile App"
        )

        do {
            try await authManager.register(request: request)
            isRegistered = true
        } catch let error as NetworkError {
            let message = error.errorDescription ?? String(localized: "Registration failed. Please try again.")
            apiError = message
            mapAPIErrorToFields(message)
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
        check(Validator.phone(mobile))              { mobileError          = $0 }
        check(Validator.email(email))               { emailError           = $0 }
        check(Validator.password(password))         { passwordError        = $0 }
        check(Validator.confirmPassword(confirmPassword, matching: password)) { confirmPasswordError = $0 }
        check(Validator.pan(panNumber))             { panNumberError       = $0 }
        check(Validator.requiredText(panCardName,  fieldName: "Name on PAN card")) { panCardNameError = $0 }
        check(Validator.requiredText(companyName,  fieldName: "Company name"))     { companyNameError = $0 }
        check(Validator.requiredText(address,      fieldName: "Address"))          { addressError     = $0 }
        check(Validator.pinCode(pinCode))           { pinCodeError         = $0 }
        check(Validator.requiredText(city,         fieldName: "City"))             { cityError        = $0 }

        if selectedCountry.name.isEmpty { countryError = String(localized: "Please select a country"); valid = false }
        if selectedState.isEmpty        { stateError   = String(localized: "Please enter a state");    valid = false }

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

    // Parses the server error message and highlights the relevant field.
    // The full message is still shown in the API error banner.
    private func mapAPIErrorToFields(_ message: String) {
        let lower = message.lowercased()
        let hint  = String(localized: "Already registered")
        if lower.contains("mobile") || lower.contains("phone") {
            mobileError = hint
        } else if lower.contains("email") {
            emailError = hint
        } else if lower.contains("pan") {
            panNumberError = hint
        } else if lower.contains("agency") || lower.contains("company") {
            companyNameError = hint
        } else if lower.contains("aadhar") || lower.contains("aadhaar") {
            // Aadhaar maps to idCardNumber — no dedicated error property; banner covers it
        }
    }
}

// MARK: - String Helpers

private extension String {
    var trimmed: String    { trimmingCharacters(in: .whitespaces) }
    var trimmedOrNil: String? { trimmed.isEmpty ? nil : trimmed }
}
