//
//  SignUpPresenter.swift
//  Origenes Bordados
//
//  Created by origenes bordados on 15/10/26.
//

import Foundation

// MARK: - Protocolo de la vista
protocol SignUpView: AnyObject {
    func showNameError(message: String?)
    func showEmailError(message: String?)
    func showPhoneError(message: String?)
    func showPasswordError(message: String?)
    func showConfirmPasswordError(message: String?)
    func showAddressError(message: String?)
    func showCityError(message: String?)
    func setSignUpButtonEnabled(_ isEnabled: Bool)
    func manageLoader(_ isLoading: Bool)
    func showSignUpSuccess()
    func showSignUpError(message: String)
}

// MARK: - Presenter
final class SignUpPresenter {

    weak var view: SignUpView?
    private let onSignUpSuccess: () -> Void

    // Estado del formulario
    private var name = ""
    private var email = ""
    private var phone = ""
    private var password = ""
    private var confirmPassword = ""
    private var address = ""
    private var city = ""

    init(onSignUpSuccess: @escaping () -> Void) {
        self.onSignUpSuccess = onSignUpSuccess
    }

    // MARK: - Validaciones individuales
    private func nameError(_ value: String) -> String? {
        let t = value.trimmingCharacters(in: .whitespaces)
        if t.isEmpty { return "Ingresa tu nombre completo" }
        if t.count < 3 { return "El nombre es demasiado corto" }
        return nil
    }

    private func emailError(_ value: String) -> String? {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        if value.range(of: regex, options: .regularExpression) == nil {
            return "Ingresa un correo válido"
        }
        return nil
    }

    private func phoneError(_ value: String) -> String? {
        let digits = value.filter { $0.isNumber }
        if digits.count < 10 { return "Ingresa un teléfono de 10 dígitos" }
        return nil
    }

    private func passwordError(_ value: String) -> String? {
        if value.count < 6 { return "Mínimo 6 caracteres" }
        return nil
    }

    private func confirmPasswordError(_ confirm: String) -> String? {
        if password != confirm { return "Las contraseñas no coinciden" }
        return nil
    }

    private func addressError(_ value: String) -> String? {
        if value.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Ingresa tu dirección"
        }
        return nil
    }

    private func cityError(_ value: String) -> String? {
        if value.trimmingCharacters(in: .whitespaces).isEmpty {
            return "Ingresa tu ciudad"
        }
        return nil
    }

    // MARK: - Edición por campo
    func nameDidEndEditing(_ value: String) {
        name = value
        view?.showNameError(message: nameError(value))
    }

    func emailDidEndEditing(_ value: String) {
        email = value
        view?.showEmailError(message: emailError(value))
    }

    func phoneDidEndEditing(_ value: String) {
        phone = value
        view?.showPhoneError(message: phoneError(value))
    }

    func passwordDidEndEditing(_ value: String) {
        password = value
        view?.showPasswordError(message: passwordError(value))
        // Revalidar confirmación por si ya estaba escrita
        if !confirmPassword.isEmpty {
            view?.showConfirmPasswordError(message: confirmPasswordError(confirmPassword))
        }
    }

    func confirmPasswordDidEndEditing(_ value: String) {
        confirmPassword = value
        view?.showConfirmPasswordError(message: confirmPasswordError(value))
    }

    func addressDidEndEditing(_ value: String) {
        address = value
        view?.showAddressError(message: addressError(value))
    }

    func cityDidEndEditing(_ value: String) {
        city = value
        view?.showCityError(message: cityError(value))
    }

    // MARK: - Cambio en vivo
    func fieldsDidChange(name: String,
                         email: String,
                         phone: String,
                         password: String,
                         confirmPassword: String,
                         address: String,
                         city: String) {
        self.name = name
        self.email = email
        self.phone = phone
        self.password = password
        self.confirmPassword = confirmPassword
        self.address = address
        self.city = city

        let isValid =
            nameError(name) == nil &&
            emailError(email) == nil &&
            phoneError(phone) == nil &&
            passwordError(password) == nil &&
            confirmPasswordError(confirmPassword) == nil &&
            addressError(address) == nil &&
            cityError(city) == nil

        view?.setSignUpButtonEnabled(isValid)
    }

    // MARK: - Acción del botón
    func requestSignUp() {
        guard nameError(name) == nil,
              emailError(email) == nil,
              phoneError(phone) == nil,
              passwordError(password) == nil,
              confirmPasswordError(confirmPassword) == nil,
              addressError(address) == nil,
              cityError(city) == nil else {
            view?.showSignUpError(message: "Revisa los datos del formulario")
            return
        }

        view?.manageLoader(true)

        // Simulación de llamada al servicio
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            self.view?.manageLoader(false)
            self.view?.showSignUpSuccess()
            self.onSignUpSuccess()
        }
    }
}
