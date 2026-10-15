//
//  WelcomePresenter.swift
//  Origenes Bordados
//
//  Created by Mario Jasso on 15/10/26.
//

import Foundation

final class WelcomePresenter {
    private let onShowLogin: () -> Void
    
    init(onShowLogin: @escaping () -> Void) {
        self.onShowLogin = onShowLogin
    }
    
    func showLogin() {
        self.onShowLogin()
    }
}
