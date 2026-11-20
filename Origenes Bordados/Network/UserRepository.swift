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
            throw UserRepositoryError.saveFailed
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
