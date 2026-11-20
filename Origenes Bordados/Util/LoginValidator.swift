//
//  LoginValidator.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administración on 20/10/26.
//

import Foundation

enum ValidationError: Equatable {
    case empty
    case invalidFormat
    case tooShort(min: Int)
    case invalidPhone(digits: Int)
    case mismatch
    
    var message: String {
        switch self{
        case .empty:
            return "Este campo es obligatorio"
        case .invalidFormat:
            return "El formato no es válido"
        case .tooShort(min: let min):
            return "Debe tener al menos \(min) caracteres"
        case .invalidPhone(digits: let digits):
            return "Ingresa un número de \(digits) dígitos"
        case .mismatch:
            return "Los valores no coinciden"
        }
    }
}

protocol LoginValidatorProtocol {
    func validateEmail (_ email: String) -> ValidationError?
    func validatePassword (_ password: String) -> ValidationError?
    func validatePasswordConfirmation(_ confirmation: String, password: String) -> ValidationError?
}

struct LoginValidator: LoginValidatorProtocol {
    private let minPasswordLength: Int = 8
    
    func validateEmail(_ email: String) -> ValidationError? {
        let trimmed = email.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return .empty }
        
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let isValid = trimmed.range(of: pattern, options: .regularExpression) != nil
        return isValid ? nil : .invalidFormat
    }
    
    func validatePassword(_ password: String) -> ValidationError?{
        guard !password.isEmpty else { return .empty }
        guard password.count >= minPasswordLength else {
            return .tooShort(min: minPasswordLength)
        }
        return nil
    }

    func validatePasswordConfirmation(_ confirmation: String, password: String) -> ValidationError? {
        guard !confirmation.isEmpty else { return .empty }
        return confirmation == password ? nil : .mismatch
    }
}
