//
//  PersonalInfoViewController.swift
//  Origenes Bordados
//

import UIKit

class PersonalInfoViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var lastNameErrorLabel: UILabel!
    @IBOutlet weak var phoneErrorLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    private let presenter: PersonalInfoPresenter
    private let phoneLength = 10

    init(presenter: PersonalInfoPresenter) {
        self.presenter = presenter
        super.init(nibName: "PersonalInfoViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    func setupView() {
        // La cuenta ya existe: no tiene sentido regresar a SignUp
        navigationItem.hidesBackButton = true

        [nameTextField, lastNameTextField, phoneTextField].forEach { field in
            field?.delegate = self
            field?.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        }
        phoneTextField.inputAccessoryView = makePhoneToolbar()
        saveButton.isEnabled = false
    }

    // El teclado numérico no tiene tecla "Listo"
    private func makePhoneToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let spacer = UIBarButtonItem(systemItem: .flexibleSpace)
        let done = UIBarButtonItem(systemItem: .done, primaryAction: UIAction { [weak self] _ in
            self?.phoneTextField.resignFirstResponder()
        })
        toolbar.items = [spacer, done]
        return toolbar
    }

    @objc private func textDidChange() {
        presenter.fieldsDidChange(name: nameTextField.text ?? "",
                                  lastName: lastNameTextField.text ?? "",
                                  phone: phoneTextField.text ?? "")
    }

    @IBAction func requestSave(_ sender: UIButton) {
        view.endEditing(true)
        presenter.didTapSave(name: nameTextField.text ?? "",
                             lastName: lastNameTextField.text ?? "",
                             phone: phoneTextField.text ?? "")
    }
}

extension PersonalInfoViewController: PersonalView {
    func showNameError(message: String?) {
        nameErrorLabel.text = message
        nameErrorLabel.isHidden = message == nil
    }

    func showLastNameError(message: String?) {
        lastNameErrorLabel.text = message
        lastNameErrorLabel.isHidden = message == nil
    }

    func showPhoneError(message: String?) {
        phoneErrorLabel.text = message
        phoneErrorLabel.isHidden = message == nil
    }

    func setSaveButtonEnabled(_ isEnabled: Bool) {
        saveButton.isEnabled = isEnabled
    }

    func manageLoader(_ isLoading: Bool) {
        isLoading ? showLoader() : hideLoader()
    }

    func showErrorMessage(_ message: String) {
        let alert = UIAlertController(title: "No pudimos continuar", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        present(alert, animated: true)
    }
}

extension PersonalInfoViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == nameTextField {
            presenter.nameDidEndEditing(textField.text ?? "")
        } else if textField == lastNameTextField {
            presenter.lastNameDidEndEditing(textField.text ?? "")
        } else {
            presenter.phoneDidEndEditing(textField.text ?? "")
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            lastNameTextField.becomeFirstResponder()
        } else if textField == lastNameTextField {
            phoneTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    // Teléfono: solo dígitos y máximo 10
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField == phoneTextField else { return true }
        guard string.allSatisfy({ $0.isASCII && $0.isNumber }) else { return false }

        let current = textField.text ?? ""
        guard let textRange = Range(range, in: current) else { return false }
        return current.replacingCharacters(in: textRange, with: string).count <= phoneLength
    }
}
