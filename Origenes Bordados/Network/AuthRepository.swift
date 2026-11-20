//
//  AuthRepository.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administracíon on 12/11/26.
//

import Foundation
import FirebaseAuth

protocol AuthRepositoryProtocol {
    var currentUser: User? { get }
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() throws
}

final class FirebaseAuthRepository: AuthRepositoryProtocol {
    private let auth: Auth

    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }

    var currentUser: User? {
        auth.currentUser.map(Self.mapUser)
    }

    func signIn(email: String, password: String) async throws -> User {
        do {
            let result = try await auth.signIn(withEmail: email, password: password)
            return Self.mapUser(result.user)
        } catch {
            throw Self.mapError(error)
        }
    }

    func signUp(email: String, password: String) async throws -> User {
        do {
            let result = try await auth.createUser(withEmail: email, password: password)
            return User(id: result.user.uid, email: email)
        } catch {
            throw Self.mapError(error)
        }
    }

    func signOut() throws {
        do { try auth.signOut() } catch { throw AuthError.unknown }
    }

    // MARK: - Mapeos Firebase → dominio

    // `FirebaseAuth.User` es el de Firebase; `User` es el nuestro.
    private static func mapUser(_ fbUser: FirebaseAuth.User) -> User {
        User(id: fbUser.uid, email: fbUser.email ?? "")
    }

    /// Firebase entrega sus errores como NSError con dominio "FIRAuthErrorDomain";
    /// se leen por su código numérico para no perder el motivo real.
    private static func mapError(_ error: Error) -> AuthError {
        let nsError = error as NSError
        guard nsError.domain == AuthErrors.domain,
              let code = AuthErrorCode(rawValue: nsError.code) else {
            return .unknown
        }

        switch code {
        case .wrongPassword, .userNotFound, .invalidCredential:
            return .invalidCredentials
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .invalidEmail:
            return .invalidEmail
        case .weakPassword:
            return .weakPassword
        case .networkError:
            return .network
        default:
            return .unknown
        }
    }
}
