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
        let viewController = factory.makeWelcomeViewController(
            onShowLogin: { [weak self] in self?.showLogin() },
            onShowSignUp: { [weak self] in self?.showSignUp() }
        )
        navigationController.setViewControllers([viewController], animated: false)
    }

    private func showLogin() {
        let viewController = factory.makeLoginViewController { [weak self] in
            self?.showHome()
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showSignUp() {
        let viewController = factory.makeSignUpViewController(
            onSignUpSuccess: { [weak self] in self?.showPersonalInfo() },
            onBack: { [weak self] in self?.navigationController.popViewController(animated: true) }
        )
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showPersonalInfo() {
        let viewController = factory.makePersonalInfoViewController { [weak self] in
            self?.showHome()
        }
        navigationController.pushViewController(viewController, animated: true)
    }

    private func showHome() {
        // Pendiente: aquí crearás el Home cuando lo tengas.
        // Por ahora solo confirmamos que el flujo llega.
        print("Sesión lista → ir a Home (pendiente)")
    }
}

// MARK: - Factory protocol
protocol ViewControllerFactory {
    func makeWelcomeViewController(onShowLogin: @escaping () -> Void,
                                   onShowSignUp: @escaping () -> Void) -> UIViewController
    func makeLoginViewController(onLoginSuccess: @escaping () -> Void) -> UIViewController
    func makeSignUpViewController(onSignUpSuccess: @escaping () -> Void,
                                  onBack: @escaping () -> Void) -> UIViewController
    func makePersonalInfoViewController(onSavedPersonalInfo: @escaping () -> Void) -> UIViewController
    
    func makeHomeViewController() -> UIViewController
    
    func makeProfileViewController() -> UIViewController
}

// MARK: - DI Container
final class AppDIContainer: ViewControllerFactory {

    func makeWelcomeViewController(onShowLogin: @escaping () -> Void,
                                   onShowSignUp: @escaping () -> Void) -> UIViewController {
        let presenter = WelcomePresenter(onShowLogin: onShowLogin,
                                         onShowSignUp: onShowSignUp)
        return WelcomeViewController(presenter: presenter)
    }

    func makeLoginViewController(onLoginSuccess: @escaping () -> Void) -> UIViewController {
        let presenter = LoginPresenter(onLoginSuccess: onLoginSuccess,
                                       validator: LoginValidator(),
                                       authRepository: FirebaseAuthRepository())
        let viewController = LoginViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }

    func makeSignUpViewController(onSignUpSuccess: @escaping () -> Void,
                                  onBack: @escaping () -> Void) -> UIViewController {
        let presenter = SignUpPresenter(onSignUpSuccess: onSignUpSuccess,
                                        onBack: onBack,
                                        validator: LoginValidator(),
                                        authRepository: FirebaseAuthRepository())
        let viewController = SignUpViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }

    func makePersonalInfoViewController(onSavedPersonalInfo: @escaping () -> Void) -> UIViewController {
        let presenter = PersonalInfoPresenter(authRepository: FirebaseAuthRepository(),
                                              userRepository: UserRepository(),
                                              validator: PersonalInfoValidator(),
                                              onSavedPersonalInfo: onSavedPersonalInfo)
        let viewController = PersonalInfoViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
    
    func makeHomeViewController() -> UIViewController {
        return UIViewController()
    }
    
    func makeProfileViewController() -> UIViewController {
        return UIViewController()
    }
}


