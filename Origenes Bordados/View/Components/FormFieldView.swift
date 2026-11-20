//
//  FormFieldView.swift
//  Origenes Bordados
//
//  Campo de formulario con etiqueta, caja redondeada y un mensaje debajo.
//  - Sin error: muestra la ayuda (por ejemplo "Mínimo 8 caracteres") en gris.
//  - Con error: delinea la caja en rojo y muestra el error con un ícono.
//
//  Se configura desde el XIB con: caption, placeholder, hint, prefix y kind.
//  kind: email, password, newPassword, givenName, familyName, phone.
//

import UIKit

final class FormFieldView: UIView {

    // MARK: - Configuración desde el XIB
    @IBInspectable var caption: String = "" {
        didSet { captionLabel.text = caption; updateAccessibility() }
    }

    @IBInspectable var placeholder: String = "" {
        didSet { applyPlaceholder() }
    }

    /// Ayuda que se ve mientras no haya error.
    @IBInspectable var hint: String = "" {
        didSet { renderMessage() }
    }

    /// Texto fijo antes del campo, por ejemplo "+52".
    @IBInspectable var prefix: String = "" {
        didSet {
            prefixLabel.text = prefix
            prefixLabel.isHidden = prefix.isEmpty
        }
    }

    @IBInspectable var kind: String = "" {
        didSet { applyKind() }
    }

    // MARK: - Subvistas
    let textField = UITextField()
    private let box = UIView()
    private let captionLabel = UILabel()
    private let prefixLabel = UILabel()
    private let messageLabel = UILabel()
    private var revealButton: UIButton?

    private(set) var errorMessage: String?

    var text: String {
        get { textField.text ?? "" }
        set { textField.text = newValue }
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }

    // MARK: - API
    /// `nil` quita el error y vuelve a mostrar la ayuda.
    func setError(_ message: String?) {
        errorMessage = message
        renderMessage()
        updateBorder()
        updateAccessibility()
    }

    // MARK: - Construcción
    private func build() {
        backgroundColor = .clear

        box.layer.cornerRadius = 16
        box.layer.cornerCurve = .continuous
        box.backgroundColor = Theme.Color.inputBackground
        box.translatesAutoresizingMaskIntoConstraints = false

        captionLabel.font = Theme.Font.body(13, weight: .semibold, textStyle: .footnote)
        captionLabel.textColor = Theme.Color.textSecondary
        captionLabel.adjustsFontForContentSizeCategory = true
        captionLabel.isAccessibilityElement = false

        prefixLabel.font = Theme.Font.body(17, weight: .semibold)
        prefixLabel.textColor = Theme.Color.text
        prefixLabel.adjustsFontForContentSizeCategory = true
        prefixLabel.isHidden = true
        prefixLabel.isAccessibilityElement = false
        prefixLabel.setContentHuggingPriority(.required, for: .horizontal)
        prefixLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        textField.borderStyle = .none
        textField.font = Theme.Font.body(17)
        textField.textColor = Theme.Color.text
        textField.tintColor = Theme.Color.primary
        textField.adjustsFontForContentSizeCategory = true
        textField.heightAnchor.constraint(greaterThanOrEqualToConstant: 28).isActive = true

        messageLabel.numberOfLines = 0
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.isAccessibilityElement = false // Se lee como parte del campo

        let inputRow = UIStackView(arrangedSubviews: [prefixLabel, textField])
        inputRow.spacing = 10
        inputRow.alignment = .center

        let inner = UIStackView(arrangedSubviews: [captionLabel, inputRow])
        inner.axis = .vertical
        inner.spacing = 2
        inner.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(inner)

        let outer = UIStackView(arrangedSubviews: [box, messageLabel])
        outer.axis = .vertical
        outer.spacing = 6
        outer.translatesAutoresizingMaskIntoConstraints = false
        addSubview(outer)

        NSLayoutConstraint.activate([
            inner.topAnchor.constraint(equalTo: box.topAnchor, constant: 12),
            inner.leadingAnchor.constraint(equalTo: box.leadingAnchor, constant: 16),
            inner.trailingAnchor.constraint(equalTo: box.trailingAnchor, constant: -16),
            inner.bottomAnchor.constraint(equalTo: box.bottomAnchor, constant: -12),

            outer.topAnchor.constraint(equalTo: topAnchor),
            outer.leadingAnchor.constraint(equalTo: leadingAnchor),
            outer.trailingAnchor.constraint(equalTo: trailingAnchor),
            outer.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // Tocar cualquier parte de la caja activa el campo.
        let focusTap = UITapGestureRecognizer(target: self, action: #selector(focusField))
        focusTap.cancelsTouchesInView = false
        box.addGestureRecognizer(focusTap)

        renderMessage()
        updateBorder()
    }

    @objc private func focusField() {
        textField.becomeFirstResponder()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateBorder()
        }
    }

    // MARK: - Estado visual
    private func updateBorder() {
        let hasError = errorMessage != nil
        box.layer.borderWidth = hasError ? 2 : 1
        let color = hasError ? Theme.Color.error : Theme.Color.line
        // Los CGColor no cambian solos con el modo oscuro: se resuelven aquí.
        box.layer.borderColor = color.resolvedColor(with: traitCollection).cgColor
        captionLabel.textColor = hasError ? Theme.Color.error : Theme.Color.textSecondary
    }

    private func renderMessage() {
        let font = Theme.Font.body(14, weight: .medium, textStyle: .footnote)
        if let errorMessage {
            let result = NSMutableAttributedString()
            let config = UIImage.SymbolConfiguration(font: font)
            if let icon = UIImage(systemName: "exclamationmark.circle", withConfiguration: config)?
                .withTintColor(Theme.Color.error, renderingMode: .alwaysOriginal) {
                result.append(NSAttributedString(attachment: NSTextAttachment(image: icon)))
                result.append(NSAttributedString(string: " "))
            }
            result.append(NSAttributedString(string: errorMessage))
            result.addAttributes([.font: font, .foregroundColor: Theme.Color.error],
                                 range: NSRange(location: 0, length: result.length))
            messageLabel.attributedText = result
            messageLabel.isHidden = false
        } else if !hint.isEmpty {
            messageLabel.attributedText = NSAttributedString(
                string: hint,
                attributes: [.font: Theme.Font.body(14, textStyle: .footnote),
                             .foregroundColor: Theme.Color.textSecondary])
            messageLabel.isHidden = false
        } else {
            messageLabel.attributedText = nil
            messageLabel.isHidden = true
        }
    }

    private func applyPlaceholder() {
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [.foregroundColor: Theme.Color.textSecondary.withAlphaComponent(0.75)]
        )
    }

    private func updateAccessibility() {
        textField.accessibilityLabel = caption
        textField.accessibilityHint = errorMessage ?? (hint.isEmpty ? nil : hint)
    }

    // MARK: - Tipo de campo
    private func applyKind() {
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.isSecureTextEntry = false
        textField.rightView = nil
        revealButton = nil

        switch kind {
        case "email":
            textField.keyboardType = .emailAddress
            textField.textContentType = .emailAddress
            textField.autocapitalizationType = .none
            textField.returnKeyType = .next
        case "password", "newPassword":
            textField.textContentType = kind == "password" ? .password : .newPassword
            textField.autocapitalizationType = .none
            textField.isSecureTextEntry = true
            textField.returnKeyType = .next
            addRevealButton()
        case "givenName":
            textField.textContentType = .givenName
            textField.autocapitalizationType = .words
            textField.returnKeyType = .next
        case "familyName":
            textField.textContentType = .familyName
            textField.autocapitalizationType = .words
            textField.returnKeyType = .next
        case "phone":
            textField.textContentType = .telephoneNumber
            textField.keyboardType = .numberPad
        default:
            break
        }
    }

    /// Botón de ojo para mostrar u ocultar la contraseña.
    private func addRevealButton() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: "eye")
        config.baseForegroundColor = Theme.Color.textSecondary
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 0)
        let button = UIButton(configuration: config)
        button.accessibilityLabel = "Mostrar contraseña"
        button.addTarget(self, action: #selector(toggleReveal), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        textField.rightView = button
        textField.rightViewMode = .always
        revealButton = button
    }

    @objc private func toggleReveal() {
        textField.isSecureTextEntry.toggle()
        let hidden = textField.isSecureTextEntry
        revealButton?.configuration?.image = UIImage(systemName: hidden ? "eye" : "eye.slash")
        revealButton?.accessibilityLabel = hidden ? "Mostrar contraseña" : "Ocultar contraseña"
    }
}
