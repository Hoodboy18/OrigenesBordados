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
    weak var view: PersonalView?
    private let authRepository: AuthRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    private let validator: PersonalInfoValidatorProtocol
    private let onSavedPersonalInfo: () -> Void

    init(authRepository: AuthRepositoryProtocol,
         userRepository: UserRepositoryProtocol,
         validator: PersonalInfoValidatorProtocol,
         onSavedPersonalInfo: @escaping () -> Void) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.validator = validator
        self.onSavedPersonalInfo = onSavedPersonalInfo
    }

    func nameDidEndEditing(_ name: String) {
        view?.showNameError(message: validator.validateName(name)?.message)
    }

    func lastNameDidEndEditing(_ lastName: String) {
        view?.showLastNameError(message: validator.validateName(lastName)?.message)
    }

    func phoneDidEndEditing(_ phone: String) {
        view?.showPhoneError(message: validator.validatePhone(phone)?.message)
    }

    func fieldsDidChange(name: String, lastName: String, phone: String) {
        view?.setSaveButtonEnabled(isFormValid(name: name, lastName: lastName, phone: phone))
    }

    func didTapSave(name: String, lastName: String, phone: String) {
        guard isFormValid(name: name, lastName: lastName, phone: phone) else {
            view?.showNameError(message: validator.validateName(name)?.message)
            view?.showLastNameError(message: validator.validateName(lastName)?.message)
            view?.showPhoneError(message: validator.validatePhone(phone)?.message)
            return
        }

        // El correo ya se capturó en SignUp: se toma de la sesión de Firebase Auth
        guard let user = authRepository.currentUser else {
            view?.showErrorMessage("Tu sesión expiró. Inicia sesión de nuevo")
            return
        }

        let userProfile = UserProfile(id: user.id,
                                      name: name.trimmingCharacters(in: .whitespaces),
                                      lastName: lastName.trimmingCharacters(in: .whitespaces),
                                      email: user.email,
                                      phone: phone.trimmingCharacters(in: .whitespaces))

        view?.manageLoader(true)
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                try await self.userRepository.save(userProfile)
                self.view?.manageLoader(false)
                self.onSavedPersonalInfo()
            } catch {
                self.view?.manageLoader(false)
                self.view?.showErrorMessage(error.localizedDescription)
            }
        }
    }

    private func isFormValid(name: String, lastName: String, phone: String) -> Bool {
        validator.validateName(name) == nil
            && validator.validateName(lastName) == nil
            && validator.validatePhone(phone) == nil
    }
}
