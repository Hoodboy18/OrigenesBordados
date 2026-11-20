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
    private let swipeBackDelegate: SwipeBackDelegate

    init(navigationController: UINavigationController, factory: ViewControllerFactory) {
        self.navigationController = navigationController
        self.factory = factory
        self.swipeBackDelegate = SwipeBackDelegate(navigationController: navigationController)
    }

    func start() {
        // Las pantallas traen su propio botón de regresar, así que se oculta la barra.
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.interactivePopGestureRecognizer?.delegate = swipeBackDelegate

        // Welcome es la primera pantalla
        navigationController.setViewControllers([makeWelcome()], animated: false)
    }

    private func makeWelcome() -> UIViewController {
        factory.makeWelcomeViewController(
            onShowLogin: { [weak self] in self?.showLogin() },
            onShowSignUp: { [weak self] in self?.showSignUp() }
        )
    }

    private func makeLogin(prefilledEmail: String? = nil, notice: String? = nil) -> UIViewController {
        factory.makeLoginViewController(
            prefilledEmail: prefilledEmail,
            notice: notice,
            onLoginSuccess: { [weak self] in self?.showHome() },
            onBack: { [weak self] in self?.navigationController.popViewController(animated: true) },
            onShowSignUp: { [weak self] in self?.showSignUp(replacingCurrent: true) }
        )
    }

    private func showLogin(replacingCurrent: Bool = false) {
        show(makeLogin(), replacingCurrent: replacingCurrent)
    }

    private func showSignUp(replacingCurrent: Bool = false) {
        let viewController = factory.makeSignUpViewController(
            onSignUpSuccess: { [weak self] in self?.showPersonalInfo() },
            onBack: { [weak self] in self?.navigationController.popViewController(animated: true) },
            onShowLogin: { [weak self] in self?.showLogin(replacingCurrent: true) }
        )
        show(viewController, replacingCurrent: replacingCurrent)
    }

    private func showPersonalInfo() {
        let viewController = factory.makePersonalInfoViewController { [weak self] email in
            self?.showLoginAfterSignUp(email: email)
        }
        // La cuenta ya existe: PersonalInfo queda como única pantalla, sin regreso a SignUp.
        navigationController.setViewControllers([viewController], animated: true)
    }

    /// Al terminar el registro: Welcome → Login con el correo precargado y un aviso.
    private func showLoginAfterSignUp(email: String) {
        let login = makeLogin(prefilledEmail: email,
                              notice: "¡Tu cuenta está lista! Inicia sesión para continuar.")
        navigationController.setViewControllers([makeWelcome(), login], animated: true)
    }

    private func showHome() {
        // Pendiente: aquí se mostrará el Home cuando exista.
        // Mientras tanto se confirma al usuario que sí inició sesión.
        let alert = UIAlertController(title: "¡Bienvenida, bienvenido!",
                                      message: "Iniciaste sesión correctamente. La pantalla de inicio estará lista pronto.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Aceptar", style: .default))
        navigationController.topViewController?.present(alert, animated: true)
    }

    /// Login ↔ SignUp se reemplazan entre sí para que "Regresar" siempre lleve a Welcome.
    private func show(_ viewController: UIViewController, replacingCurrent: Bool) {
        guard replacingCurrent, navigationController.viewControllers.count > 1 else {
            navigationController.pushViewController(viewController, animated: true)
            return
        }
        var stack = navigationController.viewControllers
        stack[stack.count - 1] = viewController
        navigationController.setViewControllers(stack, animated: true)
    }
}

// MARK: - Gesto de deslizar para regresar
/// Con la barra de navegación oculta, iOS desactiva el gesto de regresar;
/// este delegado lo vuelve a activar cuando hay una pantalla a la cual volver.
private final class SwipeBackDelegate: NSObject, UIGestureRecognizerDelegate {
    private weak var navigationController: UINavigationController?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        (navigationController?.viewControllers.count ?? 0) > 1
    }
}

// MARK: - Factory protocol
protocol ViewControllerFactory {
    func makeWelcomeViewController(onShowLogin: @escaping () -> Void,
                                   onShowSignUp: @escaping () -> Void) -> UIViewController
    func makeLoginViewController(prefilledEmail: String?,
                                 notice: String?,
                                 onLoginSuccess: @escaping () -> Void,
                                 onBack: @escaping () -> Void,
                                 onShowSignUp: @escaping () -> Void) -> UIViewController
    func makeSignUpViewController(onSignUpSuccess: @escaping () -> Void,
                                  onBack: @escaping () -> Void,
                                  onShowLogin: @escaping () -> Void) -> UIViewController
    func makePersonalInfoViewController(onSavedPersonalInfo: @escaping (String) -> Void) -> UIViewController
}

// MARK: - DI Container
final class AppDIContainer: ViewControllerFactory {

    func makeWelcomeViewController(onShowLogin: @escaping () -> Void,
                                   onShowSignUp: @escaping () -> Void) -> UIViewController {
        let presenter = WelcomePresenter(onShowLogin: onShowLogin,
                                         onShowSignUp: onShowSignUp)
        return WelcomeViewController(presenter: presenter)
    }

    func makeLoginViewController(prefilledEmail: String?,
                                 notice: String?,
                                 onLoginSuccess: @escaping () -> Void,
                                 onBack: @escaping () -> Void,
                                 onShowSignUp: @escaping () -> Void) -> UIViewController {
        let presenter = LoginPresenter(onLoginSuccess: onLoginSuccess,
                                       onBack: onBack,
                                       onShowSignUp: onShowSignUp,
                                       validator: LoginValidator(),
                                       authRepository: FirebaseAuthRepository(),
                                       prefilledEmail: prefilledEmail,
                                       notice: notice)
        let viewController = LoginViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }

    func makeSignUpViewController(onSignUpSuccess: @escaping () -> Void,
                                  onBack: @escaping () -> Void,
                                  onShowLogin: @escaping () -> Void) -> UIViewController {
        let presenter = SignUpPresenter(onSignUpSuccess: onSignUpSuccess,
                                        onBack: onBack,
                                        onShowLogin: onShowLogin,
                                        validator: LoginValidator(),
                                        authRepository: FirebaseAuthRepository())
        let viewController = SignUpViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }

    func makePersonalInfoViewController(onSavedPersonalInfo: @escaping (String) -> Void) -> UIViewController {
        let presenter = PersonalInfoPresenter(authRepository: FirebaseAuthRepository(),
                                              userRepository: UserRepository(),
                                              validator: PersonalInfoValidator(),
                                              onSavedPersonalInfo: onSavedPersonalInfo)
        let viewController = PersonalInfoViewController(presenter: presenter)
        presenter.view = viewController
        return viewController
    }
}
