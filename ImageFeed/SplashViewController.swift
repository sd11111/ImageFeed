
import UIKit
import SwiftKeychainWrapper

final class SplashViewController: UIViewController, AuthViewControllerDelegate {

    private let profileService = ProfileService.shared

    private let showImageFeedScreenSegueIdentifier = "ShowImageFeedScreen"

    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private var imageView: UIImageView!

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
        setupImageView()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func setupImageView() {
        let imageSplashScreenLogo = UIImage(named: "auth_screen_logo")

        imageView = UIImageView(image: imageSplashScreenLogo)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)

        guard let authViewController = storyboard.instantiateViewController(
            withIdentifier: "AuthViewController"
        ) as? AuthViewController else {
            assertionFailure("Не удалось найти AuthViewController по идентификатору")
            return
        }

        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
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
        vc.dismiss(animated: true) { [weak self] in
            guard let self else { return }

            guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
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
                    print("Ошибка получения профиля: \(error)")
                }
            }
        }
    }
}
