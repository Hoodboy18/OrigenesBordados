//
//  NoticeView.swift
//  Origenes Bordados
//
//  Aviso de éxito con ícono (por ejemplo, "Tu cuenta está lista").
//  Empieza oculto; se muestra con show(_:).
//

import UIKit

final class NoticeView: UIView {

    private let iconView = UIImageView()
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        build()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        build()
    }

    func show(_ message: String) {
        label.text = message
        accessibilityLabel = message
        isHidden = false
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    private func build() {
        backgroundColor = Theme.Color.secondary
        layer.cornerRadius = 16
        layer.cornerCurve = .continuous
        isHidden = true
        isAccessibilityElement = true

        iconView.image = UIImage(systemName: "checkmark.circle.fill")
        iconView.tintColor = Theme.Color.onSecondary
        iconView.contentMode = .scaleAspectFit
        iconView.setContentHuggingPriority(.required, for: .horizontal)
        iconView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(textStyle: .body)

        label.font = Theme.Font.body(15, weight: .medium, textStyle: .subheadline)
        label.textColor = Theme.Color.onSecondary
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = true

        let row = UIStackView(arrangedSubviews: [iconView, label])
        row.spacing = 10
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        addSubview(row)

        NSLayoutConstraint.activate([
            row.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            row.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            row.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            row.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12)
        ])
    }
}
