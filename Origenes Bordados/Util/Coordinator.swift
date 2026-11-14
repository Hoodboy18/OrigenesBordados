//
//  Coordinator.swift
//  Origenes Bordados
//
//  Created by Mario on 15/10/26.
//

import UIKit

// MARK: - AppCoordinator
final class AppCoordinator {

    private let navigationController: UINavigationController
    private let factory: ViewControllerFactory

    init(navigationController: UINavigationController, factory: ViewControllerFactory) {
        self.navigationController = navigationController
        self.factory = factory
    }

    func start() {
        // Welcome es la primera pantalla
        let viewController = factory.makeWelcomeViewController { [weak self] in
            self?.showLogin()
        }
        navigationController.setViewControllers([viewController], animated: false)
    }

    private func showLogin() {
        let viewController = factory.makeLoginViewController { [weak self] in
            self?.showHome()
        }
        // Reemplaza la pila: el Welcome desaparece, no hay "back" al splash
        navigationController.setViewControllers([viewController], animated: true)
    }

    private func showHome() {
        // Pendiente: aquí crearás el Home cuando lo tengas.
        // Por ahora solo confirmamos que el flujo llega.
        print("Login exitoso → ir a Home (pendiente)")
    }
}

// MARK: - Factory protocol
protocol ViewControllerFactory {
    func makeWelcomeViewController(onShowLogin: @escaping () -> Void) -> UIViewController
    func makeLoginViewController(onLoginSuccess: @escaping () -> Void) -> UIViewController
}

// MARK: - DI Container
final class AppDIContainer: ViewControllerFactory {

    func makeWelcomeViewController(onShowLogin: @escaping () -> Void) -> UIViewController {
        let presenter = WelcomePresenter(onShowLogin: onShowLogin)
        let viewController = WelcomeViewController(presenter: presenter)
        // Si tu WelcomePresenter no tiene `view`, esta línea sobra.
        // Si le agregas `weak var view: WelcomeView?`, descoméntala:
        // presenter.view = viewController
        return viewController
    }

    func makeLoginViewController(onLoginSuccess: @escaping () -> Void) -> UIViewController {
        let presenter = LoginPresenter(onLoginSuccess: onLoginSuccess,
                                       validator: LoginValidator())
        let viewController = LoginViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}
