//
//  LoginViewController.swift
//  Mario Jasso
//
//  Created by Mario Jasso on 15/10/26.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailErrorLabel: UILabel!
    
    @IBOutlet weak var passwordErrorLabel: UILabel!
    
    
    private let presenter: LoginPresenter
    
    init(presenter: LoginPresenter) {
        self.presenter = presenter
        super.init(nibName: "LoginViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        // Do any additional setup after loading the view.
    }
    
    func setupView(){
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc private func textDidChange(){
        presenter.fieldsDidChange(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
    }
    
    @IBAction func requestLogin(_ sender: UIButton) {
    }

}

extension LoginViewController: LoginView {
    func showEmailError(message: String?) {
        emailErrorLabel.text = message
        emailErrorLabel.isHidden = message == nil
    }
    
    func showPasswordError(message: String?) {
        passwordErrorLabel.text = message
        emailErrorLabel.isHidden = message == nil
    }
    
    func setLoginButtonEnabled(_ isEnabled: Bool) {
        loginButton.isEnabled = isEnabled
    }
    
    func manageLoader(_ isLoading: Bool) {
        isLoading ? showLoader() : hideLoader()
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField {
            presenter.emailDidEndEditing(textField.text ?? "")
        } else {
            presenter.passwordDidEndEditing(textField.text ?? "")
        }
    }
}
