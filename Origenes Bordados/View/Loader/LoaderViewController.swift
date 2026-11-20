//
//  LoaderViewController.swift
//  Origenes Bordados
//
//  Created by Orígenes Bordados on 29/10/26.
//

import UIKit
import Lottie

class LoaderViewController: UIViewController {

    @IBOutlet weak var animationContainer: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var patternView: TalaveraPatternView!
    private var animationView: LottieAnimationView?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupView()
    }

    private func setupStyle() {
        view.backgroundColor = Theme.Color.background
        titleLabel.font = Theme.Font.title(26, textStyle: .title2)
        titleLabel.textColor = Theme.Color.text
        titleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.applyBodyStyle()
        subtitleLabel.textAlignment = .center

        // VoiceOver solo lee el mensaje de carga mientras el loader está visible.
        view.accessibilityViewIsModal = true
        animationContainer.isAccessibilityElement = true
        animationContainer.accessibilityLabel = "Cargando"
    }

    private func setupView(){
        let animation = LottieAnimationView(name: "loader")
        animation.loopMode = .loop
        animation.contentMode = .scaleAspectFit
        animation.translatesAutoresizingMaskIntoConstraints = false
        animationContainer.addSubview(animation)

        NSLayoutConstraint.activate([
            animation.topAnchor.constraint(equalTo: animationContainer.topAnchor),
            animation.bottomAnchor.constraint(equalTo: animationContainer.bottomAnchor),
            animation.leadingAnchor.constraint(equalTo: animationContainer.leadingAnchor),
            animation.trailingAnchor.constraint(equalTo: animationContainer.trailingAnchor)
        ])
        animationView = animation
        animationView?.play()
    }

    deinit { //Para parar la animación
        animationView?.stop()
    }
}
