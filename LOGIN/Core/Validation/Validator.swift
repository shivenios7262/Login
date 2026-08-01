import Foundation

/// Centralised validation rules shared across all ViewModels.
/// Each method returns an error string when validation fails, or nil when valid.
enum Validator {

    static func email(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return String(localized: "Email is required") }
        let regex = /^[A-Z0-9._%+\-]+@[A-Z0-9.\-]+\.[A-Z]{2,}$/
        guard trimmed.uppercased().wholeMatch(of: regex) != nil else {
            return String(localized: "Enter a valid email address")
        }
        return nil
    }

    static func password(_ value: String) -> String? {
        if value.isEmpty { return String(localized: "Password is required") }
        if value.count < 8 { return String(localized: "Password must be at least 8 characters") }
        return nil
    }

    static func confirmPassword(_ value: String, matching original: String) -> String? {
        if value.isEmpty { return String(localized: "Please confirm your password") }
        if value != original { return String(localized: "Passwords do not match") }
        return nil
    }

    static func phone(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return String(localized: "Mobile number is required") }
        if trimmed.count != 10 || !trimmed.allSatisfy(\.isNumber) {
            return String(localized: "Enter a valid 10-digit mobile number")
        }
        return nil
    }

    static func pan(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return String(localized: "PAN number is required") }
        let regex = /^[A-Z]{5}[0-9]{4}[A-Z]{1}$/
        guard trimmed.uppercased().wholeMatch(of: regex) != nil else {
            return String(localized: "Enter a valid PAN number (e.g. ABCDE1234F)")
        }
        return nil
    }

    static func pinCode(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespaces)
        if trimmed.isEmpty { return String(localized: "Pin code is required") }
        if trimmed.count != 6 || !trimmed.allSatisfy(\.isNumber) {
            return String(localized: "Enter a valid 6-digit pin code")
        }
        return nil
    }

    static func requiredText(_ value: String, fieldName: String) -> String? {
        value.trimmingCharacters(in: .whitespaces).isEmpty
            ? String(localized: "\(fieldName) is required")
            : nil
    }
}
