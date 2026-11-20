//
//  WelcomeViewController.swift
//  Origenes Bordados
//
//  Created by Mario Jasso on 15/10/26.
//

import UIKit

class WelcomeViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var scrollBottomConstraint: NSLayoutConstraint!
    @IBOutlet private weak var patternView: TalaveraPatternView!
    @IBOutlet private weak var eyebrowLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subtitleLabel: UILabel!
    @IBOutlet private weak var loginButton: PillButton!
    @IBOutlet private weak var signUpButton: PillButton!
    @IBOutlet private weak var footerLabel: UILabel!

    // MARK: - Properties
    private let presenter: WelcomePresenter

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
        setupView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    private func setupView() {
        view.backgroundColor = Theme.Color.background
        // El mosaico llega hasta arriba, detrás de la barra de estado.
        scrollView.contentInsetAdjustmentBehavior = .never
        eyebrowLabel.applyEyebrowStyle()
        titleLabel.applyTitleStyle(size: 44)
        subtitleLabel.applyBodyStyle()
        footerLabel.applyBodyStyle(size: 13, textStyle: .footnote)
        footerLabel.textAlignment = .center
    }

    // MARK: - Actions
    @IBAction func showLogin(_ sender: UIButton) {
        presenter.showLogin()
    }

    @IBAction func showSignUp(_ sender: UIButton) {
        presenter.showSignUp()
    }
}
