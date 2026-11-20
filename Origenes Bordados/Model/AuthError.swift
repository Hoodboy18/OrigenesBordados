//
//  AuthError.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administracíon on 12/11/26.
//

import Foundation

enum AuthError: LocalizedError {
    case invalidCredentials
    case emailAlreadyInUse
    case network
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "El correo o la contraseña no son correctos"
        case .emailAlreadyInUse:
            return "Este correo ya está registrado. Inicia sesión"
        case .network:
            return "No hay conexión a internet. Inténtalo de nuevo"
        case .unknown:
            return "Ocurrió un error inesperado. Inténtalo de nuevo"
        }
    }
}
