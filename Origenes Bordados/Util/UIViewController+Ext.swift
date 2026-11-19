
//
//  UIViewController+Ext.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administración on 29/10/26.
//

// me permite mostrar lo que ponga aquí en cualquier pantalla, como el loader

import UIKit

extension UIViewController {

    // El loader vive en el navigationController (si existe) para cubrir toda la pantalla
    private var loaderHost: UIViewController {
        navigationController ?? self
    }

    private var loaderChild: LoaderViewController? {
        loaderHost.children.first { $0 is LoaderViewController } as? LoaderViewController
    }

    func showLoader() {
        guard loaderChild == nil else { return }

        let host = loaderHost

        let loader = LoaderViewController(nibName: "LoaderViewController", bundle: nil)

        host.addChild(loader)

        loader.view.frame = host.view.bounds
        loader.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        loader.view.alpha = 0

        host.view.addSubview(loader.view)

        loader.didMove(toParent: host)

        UIView.animate(withDuration: 0.2) {
            loader.view.alpha = 1
        }
    }

    func hideLoader() {
        guard let loader = loaderChild else { return }

        loader.willMove(toParent: nil)

        UIView.animate(withDuration: 0.2, animations: {
            loader.view.alpha = 0
        }, completion: { _ in
            loader.view.removeFromSuperview()
            loader.removeFromParent()
        })
    }

    func showErrorAlert(
        title: String = "Error",
        message: String,
        buttonTitle: String = "Aceptar",
        onDismiss: (() -> Void)? = nil
    ) { // las lambda, como este onDismiss, son bloques de codigo que se pasan como parametros

        guard Thread.isMainThread else {
            DispatchQueue.main.async {
                [weak self] in

                self?.showErrorAlert(
                    title: title,
                    message: message,
                    buttonTitle: buttonTitle,
                    onDismiss: onDismiss
                )
            }
            return
        }

        let presenter = topMostViewController()

        guard !(presenter is UIAlertController) else { return }

        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: buttonTitle,
                style: .default,
                handler: { _ in
                    onDismiss?()
                }
            )
        )

        presenter.present(alert, animated: true)
    }

    func showErrorAlert(
        _ error: Error,
        title: String = "Error",
        onDismiss: (() -> Void)? = nil
    ) {
        showErrorAlert(
            title: title,
            message: error.localizedDescription,
            onDismiss: onDismiss
        )
    }

    private func topMostViewController() -> UIViewController { // identificar el controlador más arriba que se esta presentando

        // verificamos que controller esta presentado, si la que se esta presentando es un ViewController regresamos esa
        if let presented = presentedViewController {
            return presented.topMostViewController() // la volvemos a llamar, es recursiva
        }

        if let navigation = self as? UINavigationController,
           let visible = navigation.visibleViewController {
            return visible.topMostViewController()
        }

        if let tabBar = self as? UITabBarController,
           let selected = tabBar.selectedViewController {
            return selected.topMostViewController()
        }

        return self // regresa self porque esta en una extensión, regresa quien sea quien llamara esta función

        // las alertas solo pueden tener un punto de partida, sino van a estar duplicadas
    }

}
