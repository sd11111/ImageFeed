
import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController, AuthViewControllerDelegate {

    private let profileService = ProfileService.shared

    private let showImageFeedScreenSegueIdentifier = "ShowImageFeedScreen"

    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let imageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: "vector")
        )
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = KeychainWrapper.standard.string(forKey: "authToken") {
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypBlack
        setupImageView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func setupImageView() {
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        guard let navigationController =
            storyboard.instantiateViewController(
                withIdentifier: "AuthNavigationController"
            ) as? UINavigationController
        else {
            assertionFailure(
                "Не удалось создать AuthNavigationController"
            )
            return
        }

        guard let authViewController =
            navigationController.viewControllers.first
                as? AuthViewController
        else {
            assertionFailure(
                "AuthViewController отсутствует в navigation stack"
            )
            return
        }

        authViewController.delegate = self
        navigationController.modalPresentationStyle = .fullScreen

        present(navigationController, animated: true)
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("Invalid window configuration")
            return
        }

        // Создаём экземпляр нужного контроллера из Storyboard с помощью ранее заданного идентификатора
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")

        // Установим в `rootViewController` полученный контроллер
        window.rootViewController = tabBarController
    }
}

extension SplashViewController {

    func didAuthenticate(_ vc: AuthViewController) {
        guard let navigationController = vc.navigationController else {
            assertionFailure(
                "AuthViewController должен находиться внутри UINavigationController"
            )
            return
        }

        navigationController.dismiss(animated: true) {
            [weak self] in

            guard let self else {
                return
            }

            guard let token = KeychainWrapper.standard.string(
                forKey: "authToken"
            ) else {
                print(
                    "[SplashViewController.didAuthenticate]: " +
                    "AuthorizationError - токен отсутствует"
                )
                return
            }

            self.fetchProfile(token: token)
        }
    }

    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()

        profileService.fetchProfile(token) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()

                guard let self else { return }

                switch result {

                case .success(let profile):
                    let username = profile.username

                    ProfileImageService.shared.fetchProfileImageURL(username: username) { _ in }

                    self.switchToTabBarController()

                case .failure(let error):
                    print(
                        "[SplashViewController.fetchProfile]: " +
                        "\(type(of: error)) - \(error.localizedDescription)"
                    )
                }
            }
        }
    }
}
