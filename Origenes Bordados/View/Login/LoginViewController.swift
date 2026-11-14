//
//  LoginViewController.swift
//  Mario Jasso
//
//  Created by Mario Jasso on 15/10/26.
//

import UIKit

class LoginViewController: UIViewController {

    // MARK: - Outlets originales
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordErrorLabel: UILabel!

    // MARK: - Outlets nuevos (para el diseño)
    @IBOutlet private weak var gradientView: UIView!
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var loginCard: UIView!

    // MARK: - Properties
    private let presenter: LoginPresenter
    private let gradientLayer = CAGradientLayer()
    private let blobLayer = CALayer()
    private let shadowTint = UIColor(named: "shadowTint") ?? UIColor.black

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
        setupGradient()
        setupOrganicBlobs()
        setupCardShadows()
        setupFields()
        animateEntrance()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = gradientView.bounds
        blobLayer.frame = gradientView.bounds
        rebuildBlobs()

        let cardPath = UIBezierPath(roundedRect: loginCard.bounds,
                                    cornerRadius: loginCard.layer.cornerRadius).cgPath
        loginCard.layer.shadowPath = cardPath

        let btnPath = UIBezierPath(roundedRect: loginButton.bounds,
                                   cornerRadius: loginButton.layer.cornerRadius).cgPath
        loginButton.layer.shadowPath = btnPath
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            gradientLayer.colors = [
                (UIColor(named: "gradientTop") ?? .systemBackground).cgColor,
                (UIColor(named: "gradientBottom") ?? .systemBackground).cgColor
            ]
            rebuildBlobs()
        }
    }

    // MARK: - Setup original
    func setupView() {
        emailTextField.delegate = self
        passwordTextField.delegate = self

        emailTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }

    // MARK: - Setup diseño (nuevo)
    private func setupGradient() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [
            (UIColor(named: "gradientTop") ?? .systemBackground).cgColor,
            (UIColor(named: "gradientBottom") ?? .systemBackground).cgColor
        ]
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
    }

    private func setupOrganicBlobs() {
        blobLayer.masksToBounds = true
        gradientView.layer.insertSublayer(blobLayer, above: gradientLayer)
    }

    private func rebuildBlobs() {
        blobLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        let bounds = gradientView.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        let colors: [CGColor] = [
            (UIColor(named: "primary") ?? .systemGreen).withAlphaComponent(0.35).cgColor,
            (UIColor(named: "secondary") ?? .systemYellow).withAlphaComponent(0.45).cgColor,
            (UIColor(named: "accent") ?? .systemOrange).withAlphaComponent(0.18).cgColor
        ]
        let rects = [
            CGRect(x: -bounds.width * 0.35, y: -bounds.height * 0.10,
                   width: bounds.width * 0.9, height: bounds.height * 0.45),
            CGRect(x: bounds.width * 0.55, y: bounds.height * 0.25,
                   width: bounds.width * 0.8, height: bounds.height * 0.40),
            CGRect(x: -bounds.width * 0.25, y: bounds.height * 0.65,
                   width: bounds.width * 0.7, height: bounds.height * 0.40)
        ]

        for (i, rect) in rects.enumerated() {
            let blob = CAShapeLayer()
            blob.fillColor = colors[i]
            blob.path = organicPath(in: rect).cgPath
            blobLayer.addSublayer(blob)
        }
    }

    private func organicPath(in rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath()
        let w = rect.width, h = rect.height, x = rect.origin.x, y = rect.origin.y
        let p0 = CGPoint(x: x + w * 0.15, y: y + h * 0.05)
        let p1 = CGPoint(x: x + w * 0.90, y: y + h * 0.10)
        let p2 = CGPoint(x: x + w * 0.85, y: y + h * 0.85)
        let p3 = CGPoint(x: x + w * 0.10, y: y + h * 0.90)
        path.move(to: p0)
        path.addCurve(to: p1, controlPoint1: CGPoint(x: x + w * 0.50, y: y - h * 0.15),
                      controlPoint2: CGPoint(x: x + w * 1.10, y: y + h * 0.20))
        path.addCurve(to: p2, controlPoint1: CGPoint(x: x + w * 1.10, y: y + h * 0.60),
                      controlPoint2: CGPoint(x: x + w * 0.95, y: y + h * 1.05))
        path.addCurve(to: p3, controlPoint1: CGPoint(x: x + w * 0.40, y: y + h * 1.10),
                      controlPoint2: CGPoint(x: x - w * 0.05, y: y + h * 0.70))
        path.addCurve(to: p0, controlPoint1: CGPoint(x: x - w * 0.05, y: y + h * 0.20),
                      controlPoint2: CGPoint(x: x + w * 0.05, y: y - h * 0.05))
        path.close()
        return path
    }

    private func setupCardShadows() {
        loginCard.layer.masksToBounds = false
        loginCard.layer.shadowColor = shadowTint.cgColor
        loginCard.layer.shadowOffset = CGSize(width: 0, height: 14)
        loginCard.layer.shadowRadius = 26
        loginCard.layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.35 : 0.14

        loginButton.layer.masksToBounds = false
        loginButton.layer.shadowColor = (UIColor(named: "accent") ?? shadowTint).cgColor
        loginButton.layer.shadowOffset = CGSize(width: 0, height: 10)
        loginButton.layer.shadowRadius = 18
        loginButton.layer.shadowOpacity = 0.28
    }

    private func setupFields() {
        [emailTextField, passwordTextField].forEach { field in
            guard let field = field else { return }
            field.borderStyle = .none
            field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
            field.leftViewMode = .always
            field.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 1))
            field.rightViewMode = .always
            let ph = UIColor(named: "textSecondary") ?? .secondaryLabel
            field.attributedPlaceholder = NSAttributedString(
                string: field.placeholder ?? "",
                attributes: [.foregroundColor: ph]
            )
        }
    }

    private func animateEntrance() {
        let views: [UIView?] = [loginCard, loginButton]
        views.enumerated().forEach { index, v in
            guard let v = v else { return }
            v.alpha = 0
            v.transform = CGAffineTransform(translationX: 0, y: 24)
            UIView.animate(withDuration: 0.6, delay: 0.15 * Double(index),
                           usingSpringWithDamping: 0.8, initialSpringVelocity: 0.6,
                           options: [.curveEaseOut]) {
                v.alpha = 1
                v.transform = .identity
            }
        }
    }

    // MARK: - Actions originales
    @objc private func textDidChange() {
        presenter.fieldsDidChange(email: emailTextField.text ?? "", password: passwordTextField.text ?? "")
    }

    @IBAction func requestLogin(_ sender: UIButton) {
        // vacío como lo tenías; el presenter lo maneja desde el XIB
    }
}

// MARK: - LoginView (con bug corregido en showPasswordError)
extension LoginViewController: LoginView {
    func showEmailError(message: String?) {
        emailErrorLabel.text = message
        emailErrorLabel.isHidden = message == nil
    }

    func showPasswordError(message: String?) {
        passwordErrorLabel.text = message
        passwordErrorLabel.isHidden = message == nil   // ✅ corregido (antes tocaba emailErrorLabel)
    }

    func setLoginButtonEnabled(_ isEnabled: Bool) {
        loginButton.isEnabled = isEnabled
    }

    func manageLoader(_ isLoading: Bool) {
        isLoading ? showLoader() : hideLoader()
    }
}

// MARK: - UITextFieldDelegate (igual que lo tenías)
extension LoginViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == emailTextField {
            presenter.emailDidEndEditing(textField.text ?? "")
        } else {
            presenter.passwordDidEndEditing(textField.text ?? "")
        }
    }
}
