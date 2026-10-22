//
//  SignupValidador.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administración on 22/10/26.
//

import Foundation

enum SignUpValidationError: Equatable {
    case empty
    case invalidFormat
    case tooShort(min: Int)
    
    var message: String {
        switch self {
        case .empty:
            return "Campo obligatorio"
        case .invalidFormat:
            return "Formato inválido"
        case .tooShort(let min):
            return "Mínimo \(min) caracteres"
        }
    }
}

protocol SignUpValidatorProtocol {
    func validateName (_ name: String) -> SignUpValidationError?
    func validateLastName (_ lastName: String) -> SignUpValidationError?
    func validateEmail (_ email: String) -> SignUpValidationError?
    func valitePhonenumber (_ phone: String) -> SignUpValidationError?
    func validatePassword (_ password: String) -> SignUpValidationError?
    func validateConfirmPassword (_ confirmPassword: String, password: String) -> SignUpValidationError?
    func validateMainAdress (_ mainAdress: String) -> SignUpValidationError?
    func validateNeighbourhood (_ neighbourhood: String) -> SignUpValidationError?
    func validatePostalCode (_ postalCode: String) -> SignUpValidationError?
}

struct SignupValidator : SignUpValidatorProtocol {
    private let minLength: Int = 8
    
    func validateName(_ name: String) -> SignUpValidationError? {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return .empty }
        
        let pattern = "^[a-zA-Z\\s]*$"
        let isValid = trimmed.range(of: pattern, options: .regularExpression) != nil
        
        return isValid ? nil : .invalidFormat
    }
    
    func validateLastName(_ lastName: String) -> SignUpValidationError? {
        let trimmed = lastName.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return .empty }
        
        let pattern = "^[a-zA-Z\\s]*$"
        let isValid = trimmed.range(of: pattern, options: .regularExpression) != nil
        
        return isValid ? nil : .invalidFormat
    }
    
    func
}
