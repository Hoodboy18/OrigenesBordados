//
//  RestorePasswordPresenter.swift
//  Origenes Bordados
//
//  Created by Mario Jasso on 15/10/26.
//

import Foundation

// MARK: - Protocolo de la vista
protocol RestorePasswordView: AnyObject {
    func showEmailError(message: String?)
    func setSendButtonEnabled(_ isEnabled: Bool)
    func manageLoader(_ isLoading: Bool)
    func showSuccess(message: String)
    func showError(message: String)
}

// MARK: - Presenter
final class RestorePasswordPresenter {

    weak var view: RestorePasswordView?
    private let onBackToLogin: () -> Void
    private var email = ""

    init(onBackToLogin: @escaping () -> Void) {
        self.onBackToLogin = onBackToLogin
    }

    // MARK: - Validación
    private func emailError(_ value: String) -> String? {
        let t = value.trimmingCharacters(in: .whitespaces)
        if t.isEmpty { return "Ingresa tu correo" }
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        if t.range(of: regex, options: .regularExpression) == nil {
            return "Ingresa un correo válido"
        }
        return nil
    }

    // MARK: - Edición
    func emailDidEndEditing(_ value: String) {
        email = value
        view?.showEmailError(message: emailError(value))
    }

    func fieldsDidChange(email: String) {
        self.email = email
        let isValid = emailError(email) == nil
        view?.setSendButtonEnabled(isValid)
    }

    // MARK: - Acción
    func requestRestore() {
        guard emailError(email) == nil else {
            view?.showError(message: "Ingresa un correo válido")
            return
        }

        view?.manageLoader(true)

        // Simulación de envío de correo
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.view?.manageLoader(false)
            self.view?.showSuccess(
                message: "Te enviamos un correo con las instrucciones para recuperar tu contraseña."
            )
        }
    }

    func goBackToLogin() {
        onBackToLogin()
    }
}
