//
//  WelcomeViewController.swift
//  Origenes Bordados
//
//  Created by Mario Jasso on 15/10/26.
//

import UIKit

class WelcomeViewController: UIViewController {

    // MARK: - Outlets (deben coincidir con el XIB)
    @IBOutlet private weak var blobTop: UIView!
    @IBOutlet private weak var blobRight: UIView!
    @IBOutlet private weak var arcView: UIView!
    @IBOutlet private weak var logoImageView: UIImageView!
    @IBOutlet private weak var welcomeLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var taglineLabel: UILabel!
    @IBOutlet private weak var footerLabel: UILabel!

    // MARK: - Properties
    private let presenter: WelcomePresenter
    private let gradientLayer = CAGradientLayer()

    // MARK: - Init
    init(presenter: WelcomePresenter) {
        self.presenter = presenter
        super.init(nibName: "WelcomeViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradient()
        setupTypography()
        animateIn()
        startBreathing()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer.frame = view.bounds
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateGradientColors()
        }
    }

    // MARK: - Setup
    private func setupGradient() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        view.layer.insertSublayer(gradientLayer, at: 0)
        updateGradientColors()
    }

    private func updateGradientColors() {
        gradientLayer.colors = [
            UIColor(named: "gradientTop")!.cgColor,
            UIColor(named: "gradientBottom")!.cgColor
        ]
    }

    private func setupTypography() {
        welcomeLabel.attributedText = NSAttributedString(
            string: "Hecho\na mano,\ncon alma.",
            attributes: [.kern: -1.2]
        )
        taglineLabel.attributedText = NSAttributedString(
            string: "TRADICIÓN · CALIDAD · CORAZÓN",
            attributes: [.kern: 2.0]
        )
    }

    // MARK: - Animations
    private func animateIn() {
        [blobTop, blobRight, arcView].forEach {
            $0?.alpha = 0
            $0?.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }
        welcomeLabel.alpha = 0
        welcomeLabel.transform = CGAffineTransform(translationX: -20, y: 0)

        UIView.animate(withDuration: 1.0, delay: 0.1, options: [.curveEaseOut]) {
            self.blobTop?.alpha = 0.40
            self.blobRight?.alpha = 0.65
            self.arcView?.alpha = 0.20
            self.blobTop?.transform = .identity
            self.blobRight?.transform = .identity
            self.arcView?.transform = .identity
        }

        UIView.animate(withDuration: 0.8, delay: 0.4, options: [.curveEaseOut]) {
            self.welcomeLabel.alpha = 1
            self.welcomeLabel.transform = .identity
        }
    }

    private func startBreathing() {
        UIView.animate(withDuration: 6.0,
                       delay: 1.0,
                       options: [.autoreverse, .repeat, .curveEaseInOut, .allowUserInteraction]) {
            self.blobRight?.transform = CGAffineTransform(scaleX: 1.08, y: 1.08)
            self.blobTop?.transform = CGAffineTransform(scaleX: 0.94, y: 0.94)
        }
    }

    // MARK: - Actions
    @IBAction func showLogin(_ sender: UIButton) {
        presenter.showLogin()
    }
}
