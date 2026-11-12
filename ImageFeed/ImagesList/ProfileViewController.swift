
import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {

    // MARK: Private UI Variables

    private let profileService = ProfileService.shared

    private var profileImageServiceObserver: NSObjectProtocol?

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
        label.text = "Екатерина Новикова"
        label.font = UIFont.systemFont(ofSize: 23, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var profileUsernameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypGray
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var profileStatusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypWhite
        label.text = "Hello, world!"
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

        if let profile = profileService.profile {
            updateProfileDetails(profile: profile)
        }

        // ДОБАВЛЕНО: подписка на изменение URL аватарки
        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: ProfileImageService.shared,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }

        updateAvatar()
    }

    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    // MARK: Private methods

    private func updateProfileDetails(profile: Profile) {
        profileNameLabel.text = profile.name
        profileUsernameLabel.text = profile.loginName
        profileStatusLabel.text = profile.bio
    }

    private func updateAvatar() {
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
        print("Нажата кнопка выхода")
    }
}
