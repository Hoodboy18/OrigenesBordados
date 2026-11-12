//
//  RestorePasswordViewController.swift
//  Origenes Bordados
//
//  Created by Facultad de Contaduría y Administración on 29/09/26.
//

import UIKit

class RestorePasswordViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    private let presenter: SignUpPresenter

    init(presenter: SignUpPresenter) {
        self.presenter = presenter
        super.init(nibName: "SignUpViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
