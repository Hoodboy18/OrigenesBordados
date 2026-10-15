//
//  LoginPresenter.swift
//  Origenes Bordados
//
//  Created by Mario Jasso on 15/10/26.
//

import Foundation

protocol LoginView: AnyObject {
    
}

final class LoginPresenter {
    weak var view: LoginView?
    private let onLoginSuccess: () -> Void
    
    init(onLoginSuccess: @escaping () -> Void) {
        self.onLoginSuccess = onLoginSuccess
    }
}
