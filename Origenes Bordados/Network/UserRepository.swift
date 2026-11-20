//
//  UserRepository.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administracíon on 12/11/26.
//

import Foundation
import FirebaseFirestore

protocol UserRepositoryProtocol {
    func save(_ user: UserProfile) async throws
    func fetch(userId: String) async throws -> UserProfile?
}

final class UserRepository: UserRepositoryProtocol {
    private let collection: CollectionReference

    init(db: Firestore = Firestore.firestore()) {
        self.collection = db.collection("users")
    }

    // Documento: users/{uid}
    func save(_ user: UserProfile) async throws {
        let data: [String: Any] = [
            "name": user.name,
            "lastName": user.lastName,
            "email": user.email,
            "phone": user.phone
        ]

        do {
            try await collection.document(user.id).setData(data, merge: true)
        } catch {
            print("Firestore no pudo guardar users/\(user.id): \(error)")
            throw Self.mapError(error)
        }
    }

    /// Códigos de FirestoreErrorDomain: 7 = sin permiso, 16 = sin sesión, 14 = servidor no disponible.
    private static func mapError(_ error: Error) -> UserRepositoryError {
        let nsError = error as NSError
        guard nsError.domain == FirestoreErrorDomain else { return .saveFailed }
        switch nsError.code {
        case 7, 16: return .permissionDenied
        case 14: return .unavailable
        default: return .saveFailed
        }
    }

    func fetch(userId: String) async throws -> UserProfile? {
        do {
            let snapShot = try await collection.document(userId).getDocument()
            guard let data = snapShot.data() else {
                return nil
            }

            return UserProfile(id: userId,
                               name: data["name"] as? String ?? "",
                               lastName: data["lastName"] as? String ?? "",
                               email: data["email"] as? String ?? "",
                               phone: data["phone"] as? String ?? "")
        } catch {
            throw UserRepositoryError.loadFailed
        }
    }
}
