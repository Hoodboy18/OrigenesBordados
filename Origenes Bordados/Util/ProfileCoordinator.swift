//
//  HomrCoordinator.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administración on 17/11/26.
//

import Foundation
import UIKit

protocol ProfileCoordinator: AnyObject {
    func start ()
    
}

final class AppProfileCoordinator: ProfileCoordinator {
    
    let navigationController = UINavigationController()
    private let factory: ViewControllerFactory
    
}
