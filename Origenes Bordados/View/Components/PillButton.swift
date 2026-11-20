//
//  PillButton.swift
//  Origenes Bordados
//
//  Botón principal en forma de píldora. Con "isSecondary" usa el verde suave.
//  El título se toma del XIB.
//

import UIKit

final class PillButton: UIButton {

    @IBInspectable var isSecondary: Bool = false {
        didSet { applyStyle() }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        applyStyle()
    }

    private func applyStyle() {
        let title = configuration?.title ?? title(for: .normal) ?? ""
        let background = isSecondary ? Theme.Color.secondary : Theme.Color.primary
        let foreground = isSecondary ? Theme.Color.onSecondary : Theme.Color.onPrimary

        var config = UIButton.Configuration.filled()
        config.title = title
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 16, trailing: 20)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = Theme.Font.body(17, weight: .semibold)
            return outgoing
        }
        configuration = config

        // Mantiene los colores de la marca; deshabilitado solo se atenúa.
        configurationUpdateHandler = { button in
            guard var updated = button.configuration else { return }
            updated.background.backgroundColor = button.isHighlighted
                ? background.withAlphaComponent(0.85)
                : background
            updated.baseForegroundColor = foreground
            button.configuration = updated
            button.alpha = button.isEnabled ? 1 : 0.45
        }
        setNeedsUpdateConfiguration()
    }
}
