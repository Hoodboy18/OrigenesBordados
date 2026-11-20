//
//  PersonalInfoPresenter.swift
//  Origenes Bordados
//

import Foundation

protocol PersonalView: AnyObject {
    func showNameError(message: String?)
    func showLastNameError(message: String?)
    func showPhoneError(message: String?)
    func setSaveButtonEnabled(_ isEnabled: Bool)
    func manageLoader(_ isLoading: Bool)
    func showErrorMessage(_ message: String)
}

final class PersonalInfoPresenter {

    private enum Field {
        case name, lastName, phone
    }

    weak var view: PersonalView?
    private let authRepository: AuthRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let validator: PersonalInfoValidatorProtocol
    /// Recibe el correo de la cuenta para precargarlo en el login.
    private let onSavedPersonalInfo: (String) -> Void

    /// Campos que el usuario ya dejó al menos una vez: solo esos muestran errores mientras escribe.
    private var touchedFields: Set<Field> = []

    /// Si Firestore no responde en este tiempo, se avisa al usuario en lugar de dejar el loader para siempre.
    private let saveTimeout: TimeInterval = 15
    private var saveAttempt = 0
    private var isSaving = false

    init(authRepository: AuthRepositoryProtocol,
         userRepository: UserRepositoryProtocol,
         validator: PersonalInfoValidatorProtocol,
         onSavedPersonalInfo: @escaping (String) -> Void) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.validator = validator
        self.onSavedPersonalInfo = onSavedPersonalInfo
    }

    // MARK: - Validación por campo
    func nameDidEndEditing(_ name: String) {
        touchedFields.insert(.name)
        view?.showNameError(message: nameMessage(name, field: "tu nombre"))
    }

    func lastNameDidEndEditing(_ lastName: String) {
        touchedFields.insert(.lastName)
        view?.showLastNameError(message: nameMessage(lastName, field: "tus apellidos"))
    }

    func phoneDidEndEditing(_ phone: String) {
        touchedFields.insert(.phone)
        view?.showPhoneError(message: phoneMessage(phone))
    }

    /// Se llama con cada tecla: actualiza los errores ya visibles y el botón.
    func fieldsDidChange(name: String, lastName: String, phone: String) {
        if touchedFields.contains(.name) {
            view?.showNameError(message: nameMessage(name, field: "tu nombre"))
        }
        if touchedFields.contains(.lastName) {
            view?.showLastNameError(message: nameMessage(lastName, field: "tus apellidos"))
        }
        if touchedFields.contains(.phone) {
            view?.showPhoneError(message: phoneMessage(phone))
        }
        view?.setSaveButtonEnabled(isFormValid(name: name, lastName: lastName, phone: phone))
    }

    // MARK: - Guardar en Firestore
    func didTapSave(name: String, lastName: String, phone: String) {
        guard !isSaving else { return }
        touchedFields = [.name, .lastName, .phone]
        guard isFormValid(name: name, lastName: lastName, phone: phone) else {
            view?.showNameError(message: nameMessage(name, field: "tu nombre"))
            view?.showLastNameError(message: nameMessage(lastName, field: "tus apellidos"))
            view?.showPhoneError(message: phoneMessage(phone))
            view?.setSaveButtonEnabled(false)
            return
        }

        // El correo ya se capturó en SignUp: se toma de la sesión de Firebase Auth
        guard let user = authRepository.currentUser else {
            view?.showErrorMessage("Tu sesión expiró. Regresa e inicia sesión de nuevo.")
            return
        }

        let userProfile = UserProfile(id: user.id,
                                      name: name.trimmingCharacters(in: .whitespaces),
                                      lastName: lastName.trimmingCharacters(in: .whitespaces),
                                      email: user.email,
                                      phone: phone.trimmingCharacters(in: .whitespaces))

        isSaving = true
        saveAttempt += 1
        let attempt = saveAttempt
        view?.manageLoader(true)

        // Respaldo: si Firestore no contesta, se quita el loader y se explica el problema.
        DispatchQueue.main.asyncAfter(deadline: .now() + saveTimeout) { [weak self] in
            guard let self, self.isSaving, self.saveAttempt == attempt else { return }
            self.isSaving = false
            self.view?.manageLoader(false)
            self.view?.showErrorMessage("No pudimos guardar tus datos. Revisa tu conexión a internet e inténtalo de nuevo.")
        }

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                try await self.userRepository.save(userProfile)
                guard self.isSaving, self.saveAttempt == attempt else { return }
                self.isSaving = false
                self.view?.manageLoader(false)
                // El usuario vuelve a entrar con su correo y contraseña desde el login.
                try? self.authRepository.signOut()
                self.onSavedPersonalInfo(user.email)
            } catch {
                guard self.isSaving, self.saveAttempt == attempt else { return }
                self.isSaving = false
                self.view?.manageLoader(false)
                self.view?.showErrorMessage(error.localizedDescription)
            }
        }
    }

    // MARK: - Mensajes
    private func nameMessage(_ value: String, field: String) -> String? {
        switch validator.validateName(value) {
        case .none: return nil
        case .empty: return "Escribe \(field)."
        case .tooShort(let min): return "Debe tener al menos \(min) letras."
        default: return "Usa solo letras, espacios, puntos o guiones."
        }
    }

    private func phoneMessage(_ phone: String) -> String? {
        switch validator.validatePhone(phone) {
        case .none: return nil
        case .empty: return "Escribe tu número de teléfono."
        case .invalidPhone(let digits): return "El teléfono debe tener \(digits) dígitos."
        default: return "El teléfono no es válido."
        }
    }

    private func isFormValid(name: String, lastName: String, phone: String) -> Bool {
        validator.validateName(name) == nil
            && validator.validateName(lastName) == nil
            && validator.validatePhone(phone) == nil
    }
}
