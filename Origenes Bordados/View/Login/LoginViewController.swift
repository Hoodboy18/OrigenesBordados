//
//  LoginViewController.swift
//  Origenes Bordados
//
//  Created by Mario Jasso on 15/10/26.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var emailField: FormFieldView!
    @IBOutlet private weak var passwordField: FormFieldView!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var noticeView: NoticeView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var scrollBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var backButton: UIButton!
    @IBOutlet private weak var patternView: TalaveraPatternView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var signUpLinkButton: UIButton!

    // MARK: - Properties
    private let presenter: LoginPresenter

    // MARK: - Init
    init(presenter: LoginPresenter) {
        self.presenter = presenter
        super.init(nibName: "LoginViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        presenter.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    func setupView() {
        view.backgroundColor = Theme.Color.background
        followKeyboard()

        backButton.applyBackButtonStyle()
        titleLabel.applyTitleStyle()
        subtitleLabel.applyBodyStyle()
        signUpLinkButton.applyFooterLinkStyle(prefix: "¿No tienes cuenta?", action: "Regístrate aquí")
        passwordField.textField.returnKeyType = .go

        [emailField, passwordField].forEach { field in
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
        presenter.fieldsDidChange(email: emailField.text, password: passwordField.text)
    }

    @IBAction func requestLogin(_ sender: UIButton) {
        view.endEditing(true)
        presenter.requestLogin(email: emailField.text, password: passwordField.text)
    }

    @IBAction func goBack(_ sender: UIButton) {
        presenter.goBack()
    }

    @IBAction func showSignUp(_ sender: UIButton) {
        presenter.showSignUp()
    }
}

// MARK: - LoginView
extension LoginViewController: LoginView {
    func showEmailError(message: String?) {
        emailField.setError(message)
    }

    func showPasswordError(message: String?) {
        passwordField.setError(message)
    }

    func setLoginButtonEnabled(_ isEnabled: Bool) {
        loginButton.isEnabled = isEnabled
    }

    func manageLoader(_ isLoading: Bool) {
        isLoading ? showLoader() : hideLoader()
    }

    func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "No pudimos iniciar sesión", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }

    func showNotice(_ message: String) {
        noticeView.show(message)
    }

    func fillEmail(_ email: String) {
        emailField.text = email
        textDidChange()
    }
}

// MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailField.textField {
            presenter.emailDidEndEditing(emailField.text)
        } else {
            presenter.passwordDidEndEditing(passwordField.text)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField.textField {
            passwordField.textField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
            if loginButton.isEnabled { requestLogin(loginButton) }
        }
        return true
    }
}
