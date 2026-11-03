//
//  AuthError.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administración on 03/11/26.
//

import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyINUse
    case network
    case unowned
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid credentials"
        case .emailAlreadyINUse:
            return "Email already in use"
        case .network:
            return "User not found"
        case .unowned:
            return "Network error"
        }
    }
}
