//
//  SignUpViewController.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import UIKit

class SignUpViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var scrollBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var stepLabel: UILabel!
    @IBOutlet private weak var patternView: TalaveraPatternView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var emailField: FormFieldView!
    @IBOutlet private weak var passwordField: FormFieldView!
    @IBOutlet private weak var confirmPasswordField: FormFieldView!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var loginLinkButton: UIButton!

    // MARK: - Properties
    private let presenter: SignUpPresenter

    // MARK: - Init
    init(presenter: SignUpPresenter) {
        self.presenter = presenter
        super.init(nibName: "SignUpViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupView() {
        view.backgroundColor = Theme.Color.background
        followKeyboard()

        backButton.applyBackButtonStyle()
        stepLabel.applyEyebrowStyle(kern: 1.5)
        titleLabel.applyTitleStyle()
        subtitleLabel.applyBodyStyle()
        loginLinkButton.applyFooterLinkStyle(prefix: "¿Ya tienes cuenta?", action: "Inicia sesión")
        confirmPasswordField.textField.returnKeyType = .go

        [emailField, passwordField, confirmPasswordField].forEach { field in
            field?.textField.delegate = self
            field?.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        }

        view.addGestureRecognizer(DismissKeyboardTapGesture(hostView: view))
    }

    /// El scroll termina donde empieza el teclado, así el botón nunca queda tapado.
    private func followKeyboard() {
        scrollBottomConstraint.isActive = false
        scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
    }

    // MARK: - Actions
    @objc private func textDidChange() {
        presenter.fieldsDidChange(email: emailField.text,
                                  password: passwordField.text,
                                  confirmation: confirmPasswordField.text)
    }

    @IBAction func requestSignUp(_ sender: UIButton) {
        view.endEditing(true)
        presenter.requestSignUp(email: emailField.text,
                                password: passwordField.text,
                                confirmation: confirmPasswordField.text)
    }

    @IBAction func goBack(_ sender: UIButton) {
        presenter.goBack()
    }

    @IBAction func showLogin(_ sender: UIButton) {
        presenter.showLogin()
    }
}

// MARK: - SignUpView
extension SignUpViewController: SignUpView {
    func showEmailError(message: String?) {
        emailField.setError(message)
    }

    func showPasswordError(message: String?) {
        passwordField.setError(message)
    }

    func showConfirmPasswordError(message: String?) {
        confirmPasswordField.setError(message)
    }

    func setSignUpButtonEnabled(_ isEnabled: Bool) {
        signUpButton.isEnabled = isEnabled
    }

    func manageLoader(_ isLoading: Bool) {
        isLoading ? showLoader() : hideLoader()
    }

    func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "No pudimos crear tu cuenta", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case emailField.textField:
            presenter.emailDidEndEditing(emailField.text)
        case passwordField.textField:
            presenter.passwordDidEndEditing(passwordField.text, confirmation: confirmPasswordField.text)
        default:
            presenter.confirmPasswordDidEndEditing(confirmPasswordField.text, password: passwordField.text)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailField.textField:
            passwordField.textField.becomeFirstResponder()
        case passwordField.textField:
            confirmPasswordField.textField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
            if signUpButton.isEnabled { requestSignUp(signUpButton) }
        }
        return true
    }
}
