//
//  SignUpViewController.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administración on 24/09/26.
//

import UIKit

class SignUpViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headerCard: UIView!
    @IBOutlet private weak var section1: UIView!
    @IBOutlet private weak var section2: UIView!
    @IBOutlet private weak var section3: UIView!
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var emailField: UITextField!
    @IBOutlet private weak var phoneField: UITextField!
    @IBOutlet private weak var passwordField: UITextField!
    @IBOutlet private weak var confirmPasswordField: UITextField!
    @IBOutlet private weak var addressField: UITextField!
    @IBOutlet private weak var cityField: UITextField!
    @IBOutlet private weak var signUpButton: UIButton!
    @IBOutlet private weak var backButton: UIButton!

    // MARK: - Properties
    private let gradientLayer = CAGradientLayer()
    private let blobLayer = CALayer()
    private let shadowTint = UIColor(named: "shadowTint") ?? UIColor.black

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupOrganicBlobs()
        setupCardShadows()
        setupFields()
        setupButtonShadows()
        setupBackButton()
        setupKeyboardHandling()
        setupActions()
        animateEntrance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = gradientView.bounds
        blobLayer.frame = gradientView.bounds
        rebuildBlobs()
        applyCardShadowPaths()
        applyButtonShadowPath()
        applyBackButtonShadow()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateGradientColors()
            rebuildBlobs()
            applyCardShadowPaths()
            applyButtonShadowPath()
        }
    }

    // MARK: - Gradient
    private func setupGradient() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        updateGradientColors()
    }

    private func updateGradientColors() {
        gradientLayer.colors = [
            (UIColor(named: "gradientTop") ?? .systemBackground).cgColor,
            (UIColor(named: "gradientBottom") ?? .systemBackground).cgColor
        ]
    }

    // MARK: - Organic Blobs (curvas, sin cuadrados)
    private func setupOrganicBlobs() {
        blobLayer.masksToBounds = true
        gradientView.layer.insertSublayer(blobLayer, above: gradientLayer)
    }

    private func rebuildBlobs() {
        blobLayer.sublayers?.forEach { $0.removeFromSuperlayer() }

        let bounds = gradientView.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        let primaryColor = (UIColor(named: "primary") ?? .systemGreen).withAlphaComponent(0.35).cgColor
        let secondaryColor = (UIColor(named: "secondary") ?? .systemYellow).withAlphaComponent(0.45).cgColor
        let accentColor = (UIColor(named: "accent") ?? .systemOrange).withAlphaComponent(0.18).cgColor

        let blob1 = CAShapeLayer()
        blob1.fillColor = primaryColor
        blob1.path = organicPath(in: CGRect(x: -bounds.width * 0.35,
                                            y: -bounds.height * 0.10,
                                            width: bounds.width * 0.9,
                                            height: bounds.height * 0.45)).cgPath

        let blob2 = CAShapeLayer()
        blob2.fillColor = secondaryColor
        blob2.path = organicPath(in: CGRect(x: bounds.width * 0.55,
                                            y: bounds.height * 0.22,
                                            width: bounds.width * 0.8,
                                            height: bounds.height * 0.40)).cgPath

        let blob3 = CAShapeLayer()
        blob3.fillColor = accentColor
        blob3.path = organicPath(in: CGRect(x: -bounds.width * 0.25,
                                            y: bounds.height * 0.65,
                                            width: bounds.width * 0.7,
                                            height: bounds.height * 0.40)).cgPath

        [blob1, blob2, blob3].forEach { blobLayer.addSublayer($0) }
    }

    private func organicPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let w = rect.width
        let h = rect.height
        let x = rect.origin.x
        let y = rect.origin.y

        let p0 = CGPoint(x: x + w * 0.15, y: y + h * 0.05)
        let p1 = CGPoint(x: x + w * 0.90, y: y + h * 0.10)
        let p2 = CGPoint(x: x + w * 0.85, y: y + h * 0.85)
        let p3 = CGPoint(x: x + w * 0.10, y: y + h * 0.90)

        path.move(to: p0)
        path.addCurve(to: p1,
                      controlPoint1: CGPoint(x: x + w * 0.50, y: y - h * 0.15),
                      controlPoint2: CGPoint(x: x + w * 1.10, y: y + h * 0.20))
        path.addCurve(to: p2,
                      controlPoint1: CGPoint(x: x + w * 1.10, y: y + h * 0.60),
                      controlPoint2: CGPoint(x: x + w * 0.95, y: y + h * 1.05))
        path.addCurve(to: p3,
                      controlPoint1: CGPoint(x: x + w * 0.40, y: y + h * 1.10),
                      controlPoint2: CGPoint(x: x - w * 0.05, y: y + h * 0.70))
        path.addCurve(to: p0,
                      controlPoint1: CGPoint(x: x - w * 0.05, y: y + h * 0.20),
                      controlPoint2: CGPoint(x: x + w * 0.05, y: y - h * 0.05))
        path.close()
        return path
    }

    // MARK: - Cards & Shadows
    private func setupCardShadows() {
        [headerCard, section1, section2, section3].forEach { card in
            guard let card = card else { return }
            card.layer.masksToBounds = false
            card.layer.shadowColor = shadowTint.cgColor
            card.layer.shadowOffset = CGSize(width: 0, height: 14)
            card.layer.shadowRadius = 26
            card.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.35 : 0.14

            if card === section2 {
                card.layer.shadowColor = (UIColor(named: "accent") ?? shadowTint).cgColor
                card.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.25 : 0.12
            }
        }
    }

    private func applyCardShadowPaths() {
        [headerCard, section1, section2, section3].forEach { card in
            guard let card = card else { return }
            let path = UIBezierPath(roundedRect: card.bounds,
                                    cornerRadius: card.layer.cornerRadius).cgPath
            card.layer.shadowPath = path
        }
    }

    private func setupButtonShadows() {
        signUpButton.layer.masksToBounds = false
        signUpButton.layer.shadowColor = (UIColor(named: "accent") ?? shadowTint).cgColor
        signUpButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        signUpButton.layer.shadowRadius = 18
        signUpButton.layer.shadowOpacity = 0.30
    }

    private func applyButtonShadowPath() {
        let path = UIBezierPath(roundedRect: signUpButton.bounds,
                                cornerRadius: signUpButton.layer.cornerRadius).cgPath
        signUpButton.layer.shadowPath = path
    }

    private func applyBackButtonShadow() {
        backButton.layer.masksToBounds = false
        backButton.layer.shadowColor = shadowTint.cgColor
        backButton.layer.shadowOffset = CGSize(width: 0, height: 6)
        backButton.layer.shadowRadius = 12
        backButton.layer.shadowOpacity = 0.18
        let path = UIBezierPath(roundedRect: backButton.bounds,
                                cornerRadius: backButton.layer.cornerRadius).cgPath
        backButton.layer.shadowPath = path
    }

    // MARK: - Back Button (SF Symbol en código)
    private func setupBackButton() {
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        backButton.setImage(image, for: .normal)
        backButton.tintColor = UIColor(named: "textPrimary")
    }

    // MARK: - Fields
    private func setupFields() {
        let fields = [nameField, emailField, phoneField, passwordField,
                      confirmPasswordField, addressField, cityField]
        let placeholderColor = UIColor(named: "textSecondary") ?? .secondaryLabel
        let accentColor = UIColor(named: "accent") ?? .systemOrange

        fields.forEach { field in
            guard let field = field else { return }
            field.borderStyle = .none
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
            field.leftViewMode = .always
            field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
            field.rightViewMode = .always
            field.attributedPlaceholder = NSAttributedString(
                string: field.placeholder ?? "",
                attributes: [.foregroundColor: placeholderColor]
            )
            field.layer.borderWidth = 0
            field.layer.borderColor = accentColor.cgColor
            field.delegate = self
        }
    }

    // MARK: - Actions / Keyboard
    private func setupActions() {
        signUpButton.addTarget(self, action: #selector(signUpTapped), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    private func setupKeyboardHandling() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let inset = frame.height - view.safeAreaInsets.bottom
        scrollView.contentInset.bottom = inset
        scrollView.verticalScrollIndicatorInsets.bottom = inset
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        scrollView.contentInset.bottom = 0
        scrollView.verticalScrollIndicatorInsets.bottom = 0
    }

    @objc private func dismissKeyboard() { view.endEditing(true) }

    @objc private func backTapped() {
        if let nav = navigationController { nav.popViewController(animated: true) }
        else { dismiss(animated: true) }
    }

    @objc private func signUpTapped() {
        view.endEditing(true)
        guard validate() else { return }
        print("Formulario válido ✅")
    }

    // MARK: - Entrance Animation
    private func animateEntrance() {
        let cards: [UIView?] = [headerCard, section1, section2, section3]
        cards.enumerated().forEach { index, card in
            guard let card = card else { return }
            card.alpha = 0
            card.transform = CGAffineTransform(translationX: 0, y: 30)
            UIView.animate(withDuration: 0.65,
                           delay: 0.1 * Double(index),
                           usingSpringWithDamping: 0.78,
                           initialSpringVelocity: 0.6,
                           options: [.curveEaseOut]) {
                card.alpha = 1
                card.transform = .identity
            }
        }

        signUpButton.alpha = 0
        signUpButton.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        UIView.animate(withDuration: 0.5,
                       delay: 0.6,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8,
                       options: [.curveEaseOut]) {
            self.signUpButton.alpha = 1
            self.signUpButton.transform = .identity
        }
    }

    // MARK: - Validation
    private func validate() -> Bool {
        guard let name = nameField.text?.trimmingCharacters(in: .whitespaces), !name.isEmpty else {
            showAlert("Ingresa tu nombre completo"); return false
        }
        guard let email = emailField.text, isValidEmail(email) else {
            showAlert("Ingresa un correo válido"); return false
        }
        guard let phone = phoneField.text, phone.count >= 10 else {
            showAlert("Ingresa un teléfono válido"); return false
        }
        guard let pass = passwordField.text, pass.count >= 6 else {
            showAlert("La contraseña debe tener al menos 6 caracteres"); return false
        }
        guard pass == confirmPasswordField.text else {
            showAlert("Las contraseñas no coinciden"); return false
        }
        guard let address = addressField.text, !address.isEmpty else {
            showAlert("Ingresa tu dirección"); return false
        }
        guard let city = cityField.text, !city.isEmpty else {
            showAlert("Ingresa tu ciudad"); return false
        }
        return true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let regex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.range(of: regex, options: .regularExpression) != nil
    }

    private func showAlert(_ message: String) {
        let alert = UIAlertController(title: "Revisa tus datos", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension SignUpViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderWidth = 1.5
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        UIView.animate(withDuration: 0.2) {
            textField.layer.borderWidth = 0
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case nameField:            emailField.becomeFirstResponder()
        case emailField:           phoneField.becomeFirstResponder()
        case phoneField:           passwordField.becomeFirstResponder()
        case passwordField:        confirmPasswordField.becomeFirstResponder()
        case confirmPasswordField: addressField.becomeFirstResponder()
        case addressField:         cityField.becomeFirstResponder()
        case cityField:            textField.resignFirstResponder()
        default:                   textField.resignFirstResponder()
        }
        return true
    }
}
