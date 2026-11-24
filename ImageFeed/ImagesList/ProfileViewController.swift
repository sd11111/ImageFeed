
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController, ProfileViewControllerProtocol {

    // MARK: Private UI Variables

    private var presenter: ProfilePresenterProtocol!

    func configure(_ presenter: ProfilePresenterProtocol) {
        self.presenter = presenter
        presenter.view = self
    }

    private lazy var profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(resource: .userpick))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 35
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private lazy var profileNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.text = nil
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "ProfileName"
        return label
    }()

    private lazy var profileUsernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.text = nil
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.accessibilityIdentifier = "ProfileUsername"
        return label
    }()

    private lazy var profileStatusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.text = nil
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var exitButton: UIButton = {
        let button = UIButton.systemButton(
            with: UIImage(resource: .exit),
            target: self,
            action: #selector(self.didTapButton)
        )
        button.tintColor = .ypRed
        button.translatesAutoresizingMaskIntoConstraints = false
        button.accessibilityIdentifier = "logout button"
        return button
    }()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        view.addSubview(profileImageView)
        view.addSubview(profileNameLabel)
        view.addSubview(profileStatusLabel)
        view.addSubview(profileUsernameLabel)
        view.addSubview(exitButton)

        setupConstrains()

        presenter.viewDidLoad()
    }


    // MARK: Private methods

    func updateProfileDetails(profile: Profile) {
        profileNameLabel.text = profile.name
        profileUsernameLabel.text = profile.loginName
        profileStatusLabel.text = profile.bio
    }

    func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            return
        }

        profileImageView.kf.setImage(
            with: url,
            placeholder: UIImage(resource: .userpick)
        )
    }

    private func setupConstrains() {

        NSLayoutConstraint.activate([
            profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            profileImageView.widthAnchor.constraint(equalToConstant: 70),
            profileImageView.heightAnchor.constraint(equalToConstant: 70),

            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            exitButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor),
            exitButton.widthAnchor.constraint(equalToConstant: 44),
            exitButton.heightAnchor.constraint(equalToConstant: 44),

            profileNameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            profileNameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            profileNameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8),

            profileUsernameLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            profileUsernameLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            profileUsernameLabel.topAnchor.constraint(equalTo: profileNameLabel.bottomAnchor, constant: 8),

            profileStatusLabel.leadingAnchor.constraint(equalTo: profileImageView.leadingAnchor),
            profileStatusLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            profileStatusLabel.topAnchor.constraint(equalTo: profileUsernameLabel.bottomAnchor, constant: 8)
        ])
    }

    // MARK: Private actions

    @objc private func didTapButton() {
        let alert = UIAlertController(
            title: "Выход из аккаунта",
            message: "Вы уверены, что хотите выйти?",
            preferredStyle: .alert
        )

        alert.addAction(
            UIAlertAction(
                title: "Отмена",
                style: .cancel
            )
        )

        alert.addAction(
            UIAlertAction(
                title: "Выйти",
                style: .destructive
            ) { [weak self] _ in
                guard
                    let self,
                    let window = self.view.window
                else {
                    return
                }

                self.exitButton.isEnabled = false

                ProfileLogoutService.shared.logout {
                    window.rootViewController = SplashViewController()
                }
            }
        )

        present(alert, animated: true)
    }
}
