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
    case invalidEmail
    case weakPassword
    case network
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "El correo o la contraseña no son correctos."
        case .emailAlreadyInUse:
            return "Este correo ya está registrado. Inicia sesión o usa otro correo."
        case .invalidEmail:
            return "Ingresa un correo válido, por ejemplo nombre@correo.com."
        case .weakPassword:
            return "La contraseña es muy débil. Usa al menos 8 caracteres."
        case .network:
            return "No hay conexión a internet. Revisa tu conexión e inténtalo de nuevo."
        case .unknown:
            return "Ocurrió un error inesperado. Inténtalo de nuevo."
        }
    }
}
