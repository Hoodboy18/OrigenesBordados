//
//  LoginPresenter.swift
//  Origenes Bordados
//
//  Created by Mario Jasso on 15/10/26.
//

import Foundation

//todo lo que tiene que ejecutar
protocol LoginView: AnyObject {
    func showEmailError(message: String?)
    func showPasswordError(message :String?)
    func setLoginButtonEnabled(_ isEnabled: Bool)
    func manageLoader( _ isLoading: Bool)
    func showErrorMessage(_ message: String)
    func showNotice(_ message: String)
    func fillEmail(_ email: String)
}

final class LoginPresenter {

    private enum Field {
        case email, password
    }

    weak var view: LoginView?
    private let onLoginSuccess: () -> Void
    private let onBack: () -> Void
    private let onShowSignUp: () -> Void
    private let validator: LoginValidatorProtocol
    private let authRepository: AuthRepositoryProtocol
    /// Correo que se precarga (por ejemplo, al terminar el registro).
    private let prefilledEmail: String?
    /// Aviso que se muestra al abrir la pantalla.
    private let notice: String?

    /// Campos que el usuario ya dejó al menos una vez: solo esos muestran errores mientras escribe.
    private var touchedFields: Set<Field> = []

    init(onLoginSuccess: @escaping () -> Void,
         onBack: @escaping () -> Void,
         onShowSignUp: @escaping () -> Void,
         validator: LoginValidatorProtocol,
         authRepository: AuthRepositoryProtocol,
         prefilledEmail: String? = nil,
         notice: String? = nil) {
        self.onLoginSuccess = onLoginSuccess
        self.onBack = onBack
        self.onShowSignUp = onShowSignUp
        self.validator = validator
        self.authRepository = authRepository
        self.prefilledEmail = prefilledEmail
        self.notice = notice
    }

    func viewDidLoad() {
        if let notice { view?.showNotice(notice) }
        if let prefilledEmail { view?.fillEmail(prefilledEmail) }
    }

    func emailDidEndEditing(_ email: String) {
        touchedFields.insert(.email)
        view?.showEmailError(message: emailMessage(email))
    }

    func passwordDidEndEditing(_ password: String){
        touchedFields.insert(.password)
        view?.showPasswordError(message: passwordMessage(password))
    }

    /// Se llama con cada tecla: actualiza los errores ya visibles y el botón.
    func fieldsDidChange(email: String, password: String){
        if touchedFields.contains(.email) {
            view?.showEmailError(message: emailMessage(email))
        }
        if touchedFields.contains(.password) {
            view?.showPasswordError(message: passwordMessage(password))
        }
        view?.setLoginButtonEnabled(isFormValid(email: email, password: password))
    }

    func requestLogin(email: String, password: String) {
        touchedFields = [.email, .password]
        guard isFormValid(email: email, password: password) else {
            view?.showEmailError(message: emailMessage(email))
            view?.showPasswordError(message: passwordMessage(password))
            view?.setLoginButtonEnabled(false)
            return
        }

        let email = email.trimmingCharacters(in: .whitespaces)
        view?.manageLoader(true)
        Task { @MainActor [weak self] in
            guard let self = self else { return }
            do {
                _ = try await self.authRepository.signIn(email: email, password: password)
                self.view?.manageLoader(false)
                self.onLoginSuccess()
            } catch {
                self.view?.manageLoader(false)
                self.show(error)
            }
        }
    }

    func goBack() {
        onBack()
    }

    func showSignUp() {
        onShowSignUp()
    }

    // MARK: - Mensajes
    private func show(_ error: Error) {
        switch error as? AuthError {
        case .invalidCredentials:
            view?.showPasswordError(message: error.localizedDescription)
        case .invalidEmail:
            view?.showEmailError(message: error.localizedDescription)
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
        case .empty: return "Escribe tu contraseña."
        case .tooShort(let min): return "Tu contraseña tiene al menos \(min) caracteres."
        default: return "La contraseña no es válida."
        }
    }

    private func isFormValid(email: String, password: String) -> Bool {
        validator.validateEmail(email) == nil && validator.validatePassword(password) == nil
    }
}
