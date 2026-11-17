//
//  PersonalInfoValidator.swift
//  Origenes Bordados
//

import Foundation

protocol PersonalInfoValidatorProtocol {
    func validateName(_ name: String) -> ValidationError?
    func validatePhone(_ phone: String) -> ValidationError?
}

struct PersonalInfoValidator: PersonalInfoValidatorProtocol {
    private let minNameLength: Int = 2
    private let phoneLength: Int = 10

    // Sirve para nombre(s) y para apellidos
    func validateName(_ name: String) -> ValidationError? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return .empty }
        guard trimmed.count >= minNameLength else { return .tooShort(min: minNameLength) }

        let pattern = #"^[\p{L}][\p{L} .'-]*$"#
        let isValid = trimmed.range(of: pattern, options: .regularExpression) != nil
        return isValid ? nil : .invalidFormat
    }

    // Teléfono de México: exactamente 10 dígitos, sin lada internacional
    func validatePhone(_ phone: String) -> ValidationError? {
        let trimmed = phone.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return .empty }

        let isValid = trimmed.count == phoneLength && trimmed.allSatisfy { $0.isASCII && $0.isNumber }
        return isValid ? nil : .invalidPhone(digits: phoneLength)
    }
}
