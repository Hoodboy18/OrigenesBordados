//
//  PersonalInfoViewController.swift
//  Origenes Bordados
//

import UIKit

class PersonalInfoViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var nameField: FormFieldView!
    @IBOutlet private weak var lastNameField: FormFieldView!
    @IBOutlet private weak var phoneField: FormFieldView!
    @IBOutlet private weak var saveButton: UIButton!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var scrollBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var stepLabel: UILabel!
    @IBOutlet private weak var patternView: TalaveraPatternView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!

    // MARK: - Properties
    private let presenter: PersonalInfoPresenter
    private let phoneLength = 10

    // MARK: - Init
    init(presenter: PersonalInfoPresenter) {
        self.presenter = presenter
        super.init(nibName: "PersonalInfoViewController", bundle: nil)
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

    func setupView() {
        view.backgroundColor = Theme.Color.background
        followKeyboard()

        stepLabel.applyEyebrowStyle(kern: 1.5)
        titleLabel.applyTitleStyle()
        subtitleLabel.applyBodyStyle()

        [nameField, lastNameField, phoneField].forEach { field in
            field?.textField.delegate = self
            field?.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        }
        phoneField.textField.inputAccessoryView = makePhoneToolbar()
        saveButton.isEnabled = false

        view.addGestureRecognizer(DismissKeyboardTapGesture(hostView: view))
    }

    /// El scroll termina donde empieza el teclado, así el botón nunca queda tapado.
    private func followKeyboard() {
        scrollBottomConstraint.isActive = false
        scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true
    }

    // El teclado numérico no tiene tecla "Listo"
    private func makePhoneToolbar() -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let spacer = UIBarButtonItem(systemItem: .flexibleSpace)
        let done = UIBarButtonItem(systemItem: .done, primaryAction: UIAction { [weak self] _ in
            self?.phoneField.textField.resignFirstResponder()
        })
        toolbar.items = [spacer, done]
        return toolbar
    }

    // MARK: - Actions
    @objc private func textDidChange() {
        presenter.fieldsDidChange(name: nameField.text,
                                  lastName: lastNameField.text,
                                  phone: phoneField.text)
    }

    @IBAction func requestSave(_ sender: UIButton) {
        view.endEditing(true)
        presenter.didTapSave(name: nameField.text,
                             lastName: lastNameField.text,
                             phone: phoneField.text)
    }
}

// MARK: - PersonalView
extension PersonalInfoViewController: PersonalView {
    func showNameError(message: String?) {
        nameField.setError(message)
    }

    func showLastNameError(message: String?) {
        lastNameField.setError(message)
    }

    func showPhoneError(message: String?) {
        phoneField.setError(message)
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

// MARK: - UITextFieldDelegate
extension PersonalInfoViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case nameField.textField:
            presenter.nameDidEndEditing(nameField.text)
        case lastNameField.textField:
            presenter.lastNameDidEndEditing(lastNameField.text)
        default:
            presenter.phoneDidEndEditing(phoneField.text)
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField.textField:
            lastNameField.textField.becomeFirstResponder()
        case lastNameField.textField:
            phoneField.textField.becomeFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }

    // Teléfono: solo dígitos y máximo 10
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        guard textField == phoneField.textField else { return true }
        guard string.allSatisfy({ $0.isASCII && $0.isNumber }) else { return false }

        let current = textField.text ?? ""
        guard let textRange = Range(range, in: current) else { return false }
        return current.replacingCharacters(in: textRange, with: string).count <= phoneLength
    }
}
