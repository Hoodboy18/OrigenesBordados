//
//  SignUpPresenter.swift
//  Origenes Bordados
//
//  Created by origenes bordados on 15/10/26.
//

import Foundation

// MARK: - Protocolo de la vista
protocol SignUpView: AnyObject {
    func showEmailError(message: String?)
    func showPasswordError(message: String?)
    func showConfirmPasswordError(message: String?)
    func setSignUpButtonEnabled(_ isEnabled: Bool)
    func manageLoader(_ isLoading: Bool)
    func showErrorMessage(_ message: String)
}

// MARK: - Presenter
final class SignUpPresenter {

    private enum Field {
        case email, password, confirmPassword
    }

    weak var view: SignUpView?
    private let onSignUpSuccess: () -> Void
    private let onBack: () -> Void
    private let onShowLogin: () -> Void
    private let validator: LoginValidatorProtocol
    private let authRepository: AuthRepositoryProtocol

    /// Campos que el usuario ya dejó al menos una vez: solo esos muestran errores mientras escribe.
    private var touchedFields: Set<Field> = []

    init(onSignUpSuccess: @escaping () -> Void,
         onBack: @escaping () -> Void,
         onShowLogin: @escaping () -> Void,
         validator: LoginValidatorProtocol,
         authRepository: AuthRepositoryProtocol) {
        self.onSignUpSuccess = onSignUpSuccess
        self.onBack = onBack
        self.onShowLogin = onShowLogin
        self.validator = validator
        self.authRepository = authRepository
    }

    // MARK: - Validación por campo
    func emailDidEndEditing(_ email: String) {
        touchedFields.insert(.email)
        view?.showEmailError(message: emailMessage(email))
    }

    func passwordDidEndEditing(_ password: String, confirmation: String) {
        touchedFields.insert(.password)
        view?.showPasswordError(message: passwordMessage(password))
        if touchedFields.contains(.confirmPassword) {
            view?.showConfirmPasswordError(message: confirmationMessage(confirmation, password: password))
        }
    }

    func confirmPasswordDidEndEditing(_ confirmation: String, password: String) {
        touchedFields.insert(.confirmPassword)
        view?.showConfirmPasswordError(message: confirmationMessage(confirmation, password: password))
    }

    /// Se llama con cada tecla: actualiza los errores ya visibles y el botón.
    func fieldsDidChange(email: String, password: String, confirmation: String) {
        if touchedFields.contains(.email) {
            view?.showEmailError(message: emailMessage(email))
        }
        if touchedFields.contains(.password) {
            view?.showPasswordError(message: passwordMessage(password))
        }
        if touchedFields.contains(.confirmPassword) {
            view?.showConfirmPasswordError(message: confirmationMessage(confirmation, password: password))
        }
        view?.setSignUpButtonEnabled(isFormValid(email: email, password: password, confirmation: confirmation))
    }

    // MARK: - Registro
    // Solo crea la cuenta en Firebase Auth; el perfil se guarda en PersonalInfo
    func requestSignUp(email: String, password: String, confirmation: String) {
        touchedFields = [.email, .password, .confirmPassword]
        guard isFormValid(email: email, password: password, confirmation: confirmation) else {
            view?.showEmailError(message: emailMessage(email))
            view?.showPasswordError(message: passwordMessage(password))
            view?.showConfirmPasswordError(message: confirmationMessage(confirmation, password: password))
            view?.setSignUpButtonEnabled(false)
            return
        }

        let email = email.trimmingCharacters(in: .whitespaces)
        view?.manageLoader(true)
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                _ = try await self.authRepository.signUp(email: email, password: password)
                self.view?.manageLoader(false)
                self.onSignUpSuccess()
            } catch {
                self.view?.manageLoader(false)
                self.show(error)
            }
        }
    }

    func goBack() {
        onBack()
    }

    func showLogin() {
        onShowLogin()
    }

    // MARK: - Mensajes
    private func show(_ error: Error) {
        switch error as? AuthError {
        case .emailAlreadyInUse, .invalidEmail:
            view?.showEmailError(message: error.localizedDescription)
            view?.setSignUpButtonEnabled(false)
        case .weakPassword:
            view?.showPasswordError(message: error.localizedDescription)
            view?.setSignUpButtonEnabled(false)
        default:
            view?.showErrorMessage(error.localizedDescription)
        }
    }

    private func emailMessage(_ email: String) -> String? {
        switch validator.validateEmail(email) {
        case .none: return nil
        case .empty: return "Escribe tu correo electrónico."
        default: return "Ingresa un correo válido, por ejemplo nombre@correo.com."
        }
    }

    private func passwordMessage(_ password: String) -> String? {
        switch validator.validatePassword(password) {
        case .none: return nil
        case .empty: return "Escribe una contraseña."
        case .tooShort(let min): return "La contraseña debe tener al menos \(min) caracteres."
        default: return "La contraseña no es válida."
        }
    }

    private func confirmationMessage(_ confirmation: String, password: String) -> String? {
        switch validator.validatePasswordConfirmation(confirmation, password: password) {
        case .none: return nil
        case .empty: return "Escribe de nuevo tu contraseña."
        default: return "Las contraseñas no coinciden."
        }
    }

    private func isFormValid(email: String, password: String, confirmation: String) -> Bool {
        validator.validateEmail(email) == nil
            && validator.validatePassword(password) == nil
            && validator.validatePasswordConfirmation(confirmation, password: password) == nil
    }
}
