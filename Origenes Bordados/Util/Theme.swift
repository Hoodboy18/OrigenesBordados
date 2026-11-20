//
//  Theme.swift
//  Origenes Bordados
//
//  Colores, tipografías y estilos compartidos del diseño D (talavera).
//  Los colores viven en Color.xcassets y ya traen su variante de modo oscuro.
//

import UIKit

enum Theme {

    // MARK: - Colores (nombres de Color.xcassets)
    enum Color {
        static let background = named("mainBackground", fallback: .systemBackground)
        static let secondaryBackground = named("secondaryBackground", fallback: .secondarySystemBackground)
        static let surface = named("sordSurface", fallback: .secondarySystemBackground)
        static let inputBackground = named("inputBackground", fallback: .secondarySystemBackground)
        static let line = named("divider", fallback: .separator)
        static let text = named("textPrimary", fallback: .label)
        static let textSecondary = named("textSecondary", fallback: .secondaryLabel)
        static let primary = named("primary", fallback: .systemGreen)
        static let onPrimary = named("textOnPrimary", fallback: .white)
        static let secondary = named("secondary", fallback: .secondarySystemFill)
        static let onSecondary = named("textOnSecondary", fallback: .label)
        static let accent = named("accent", fallback: .systemPink)
        static let error = named("error", fallback: .systemRed)

        private static func named(_ name: String, fallback: UIColor) -> UIColor {
            UIColor(named: name) ?? fallback
        }
    }

    // MARK: - Tipografía
    // Títulos: Bricolage Grotesque. Cuerpo: Instrument Sans.
    // Todas se escalan con el tamaño de texto del sistema (Dynamic Type).
    enum Font {
        enum Weight {
            case regular, medium, semibold

            var fontName: String {
                switch self {
                case .regular: return "InstrumentSans-Regular"
                case .medium: return "InstrumentSans-Medium"
                case .semibold: return "InstrumentSans-SemiBold"
                }
            }

            var systemWeight: UIFont.Weight {
                switch self {
                case .regular: return .regular
                case .medium: return .medium
                case .semibold: return .semibold
                }
            }
        }

        static func title(_ size: CGFloat, textStyle: UIFont.TextStyle = .largeTitle) -> UIFont {
            let base = UIFont(name: "BricolageGrotesque-SemiBold", size: size)
                ?? .systemFont(ofSize: size, weight: .semibold)
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
        }

        static func body(_ size: CGFloat,
                         weight: Weight = .regular,
                         textStyle: UIFont.TextStyle = .body) -> UIFont {
            let base = UIFont(name: weight.fontName, size: size)
                ?? .systemFont(ofSize: size, weight: weight.systemWeight)
            return UIFontMetrics(forTextStyle: textStyle).scaledFont(for: base)
        }
    }
}

// MARK: - Estilos de texto
extension UILabel {

    /// Título grande en Bricolage con interletrado cerrado.
    func applyTitleStyle(size: CGFloat = 40) {
        let text = self.text ?? ""
        font = Theme.Font.title(size)
        textColor = Theme.Color.text
        numberOfLines = 0
        adjustsFontForContentSizeCategory = true
        attributedText = NSAttributedString(string: text, attributes: [.kern: -size * 0.025])
        accessibilityTraits.insert(.header)
    }

    /// Texto pequeño en mayúsculas y rosa, arriba de los títulos.
    func applyEyebrowStyle(kern: CGFloat = 2.5) {
        let text = (self.text ?? "").uppercased()
        font = Theme.Font.body(13, weight: .semibold, textStyle: .footnote)
        textColor = Theme.Color.accent
        numberOfLines = 0
        adjustsFontForContentSizeCategory = true
        attributedText = NSAttributedString(string: text, attributes: [.kern: kern])
    }

    func applyBodyStyle(size: CGFloat = 17, color: UIColor = Theme.Color.textSecondary,
                        textStyle: UIFont.TextStyle = .body) {
        font = Theme.Font.body(size, textStyle: textStyle)
        textColor = color
        numberOfLines = 0
        adjustsFontForContentSizeCategory = true
    }
}

// MARK: - Botones
extension UIButton {

    /// Botón circular para regresar (44 × 44 pt).
    func applyBackButtonStyle() {
        var config = UIButton.Configuration.filled()
        config.image = UIImage(systemName: "chevron.left",
                               withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold))
        config.cornerStyle = .capsule
        config.baseBackgroundColor = Theme.Color.secondary
        config.baseForegroundColor = Theme.Color.onSecondary
        configuration = config
        accessibilityLabel = "Regresar"
    }

    /// Enlace del pie: "¿No tienes cuenta? Regístrate aquí".
    func applyFooterLinkStyle(prefix: String, action: String) {
        var prefixText = AttributedString(prefix + " ")
        prefixText.font = Theme.Font.body(15, textStyle: .subheadline)
        prefixText.foregroundColor = Theme.Color.textSecondary

        var actionText = AttributedString(action)
        actionText.font = Theme.Font.body(15, weight: .semibold, textStyle: .subheadline)
        actionText.foregroundColor = Theme.Color.accent

        var config = UIButton.Configuration.plain()
        config.attributedTitle = prefixText + actionText
        config.titleAlignment = .center
        config.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 8, bottom: 12, trailing: 8)
        configuration = config
        accessibilityLabel = "\(prefix) \(action)"
    }
}
