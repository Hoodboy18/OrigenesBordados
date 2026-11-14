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
    case saveFailed, loadFailed

    var errorDescription: String? {
        switch self {
        case .saveFailed:
            return "No pudimos guardar tus datos. Inténtalo de nuevo"
        case .loadFailed:
            return "No pudimos cargar tus datos. Inténtalo de nuevo"
        }
    }
}
