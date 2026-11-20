//
//  UserProfile.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administracíon on 12/11/26.
//

import Foundation

// Perfil del cliente. La dirección de envío no va aquí: se captura al comprar.
struct UserProfile: Equatable {
    let id: String
    let name: String
    let lastName: String
    let email: String
    let phone: String
}

enum UserRepositoryError: LocalizedError {
    case saveFailed, loadFailed, permissionDenied, unavailable

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "No pudimos guardar tus datos. Inténtalo de nuevo"
        case .permissionDenied:
            return "No tenemos permiso para guardar tus datos. Inicia sesión de nuevo e inténtalo otra vez."
        case .unavailable:
            return "No pudimos conectar con el servidor. Revisa tu conexión a internet e inténtalo de nuevo."
        case .loadFailed:
            return "No pudimos cargar tus datos. Inténtalo de nuevo"
        }
    }
}
