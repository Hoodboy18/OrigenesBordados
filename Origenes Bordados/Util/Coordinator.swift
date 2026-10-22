//
//  Coordinator.swift
//  Origenes Bordados
//
//  Created by Mario on 15/10/26.
//

import UIKit

final class AppCoordinator {
    private let navigationController: UINavigationController
    private let factory: ViewControllerFactory
    
    init(navigationController: UINavigationController, factory: ViewControllerFactory) {
        self.navigationController = navigationController
        self.factory = factory
    }
    
    func start() {
        let viewController = factory.makeWelcomeViewController { [weak self] in
            self?.showLogin()
        }
        navigationController.viewControllers = [viewController]
    }
    
    private func showLogin() {
        let viewController = factory.makeLoginViewController { [weak self] in
            
        }
        navigationController.pushViewController(viewController, animated: true)
    }
}

protocol ViewControllerFactory {
    func makeWelcomeViewController(onShowLogin: @escaping () -> Void) -> UIViewController
    func makeLoginViewController(onLoginSuccess: @escaping () -> Void) -> UIViewController
}

final class AppDIContainer: ViewControllerFactory {
    
    func makeWelcomeViewController(onShowLogin: @escaping () -> Void) -> UIViewController {
        let presenter = WelcomePresenter(onShowLogin: onShowLogin)
        return WelcomeViewController(presenter: presenter)
    }
    
    func makeLoginViewController(onLoginSuccess: @escaping () -> Void) -> UIViewController {
        let presenter = LoginPresenter(onLoginSuccess: onLoginSuccess, validator: LoginValidator())
        
        let viewController = LoginViewController(presenter: presenter)
        presenter.view = viewController
        
        return LoginViewController(presenter: presenter)
    }
    
}
