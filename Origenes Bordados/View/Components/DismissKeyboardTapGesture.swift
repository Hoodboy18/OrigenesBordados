//
//  DismissKeyboardTapGesture.swift
//  Origenes Bordados
//
//  Oculta el teclado al tocar fuera de los campos.
//  Ignora los toques sobre campos y botones para no cerrar el teclado por error.
//

import UIKit

final class DismissKeyboardTapGesture: UITapGestureRecognizer, UIGestureRecognizerDelegate {

    private weak var hostView: UIView?

    init(hostView: UIView) {
        self.hostView = hostView
        super.init(target: nil, action: nil)
        addTarget(self, action: #selector(handleTap))
        cancelsTouchesInView = false
        delegate = self
    }

    @objc private func handleTap() {
        hostView?.endEditing(true)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var view = touch.view
        while let current = view {
            if current is FormFieldView || current is UITextField || current is UIControl {
                return false
            }
            view = current.superview
        }
        return true
    }
}
