//
//  RestorePasswordViewController.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administración on 29/09/26.
//

import UIKit

// Pendiente: esta pantalla todavía no forma parte del flujo (igual que en el proyecto de referencia).
class RestorePasswordViewController: UIViewController {

    private let presenter: RestorePasswordPresenter

    init(presenter: RestorePasswordPresenter) {
        self.presenter = presenter
        super.init(nibName: "RestorePasswordViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
}
