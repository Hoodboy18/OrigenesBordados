//
//  HomrCoordinator.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administración on 17/11/26.
//

import Foundation
import UIKit

protocol HomeCoordinator: AnyObject {
    func start ()
}

final class AppHomeCoordinator: HomeCoordinator{
    
    let navigationController = UINavigationController()
    private let factory: ViewControllerFactory
    
    init (factory: ViewControllerFactory){
        self.factory = factory
        navigationController.tabBarItem = UITabBarItem(title: "Inicio", image: UIImage(systemName: "house"), selectedImage: UIImage(systemName: "house.fill"))
    }
    
    func start () {
        let home = factory.makeHomeViewController()
        navigationController.setViewControllers([home], animated: true)
    }

}
