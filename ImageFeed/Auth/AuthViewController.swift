import UIKit
import WebKit
import ProgressHUD

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let showWebView = "ShowWebView"
}

final class AuthViewController: UIViewController {
    weak var delegate: AuthViewControllerDelegate?
    private let oauth2Service = OAuth2Service.shared
    private func configureBackButton() {
        navigationController?.navigationBar.backIndicatorImage = UIImage(named: "nav_back_button")
        navigationController?.navigationBar.backIndicatorTransitionMaskImage = UIImage(named: "nav_back_button")
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationItem.backBarButtonItem?.tintColor = UIColor(named: "ypBlack")
    }
    
    private func showAuthErrorAlert() {
        let alert = UIAlertController(
            title: "Что-то пошло не так",
            message: "Не удалось войти в систему",
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(
            title: "Ок",
            style: .default
        ))

        present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == WebViewConstants.showWebView {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                assertionFailure("Failed to prepare")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureBackButton()
    }
}

extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(
        _ vc: WebViewViewController,
        didAuthenticateWithCode code: String
    ) {
        guard let navigationController = vc.navigationController else {
            print(
                "[AuthViewController.webViewViewController]: " +
                "NavigationError - UINavigationController отсутствует"
            )
            return
        }

        navigationController.popViewController(animated: true)

        UIBlockingProgressHUD.show()

        oauth2Service.fetchOAuthToken(code: code) {
            [weak self] result in

            UIBlockingProgressHUD.dismiss()

            guard let self else {
                return
            }

            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)

            case .failure(let error):
                print(
                    "[AuthViewController.fetchOAuthToken]: " +
                    "\(type(of: error)) - \(error.localizedDescription)"
                )
                self.showAuthErrorAlert()
            }
        }
    }

    func webViewViewControllerDidCancel(
        _ vc: WebViewViewController
    ) {
        vc.navigationController?
            .popViewController(animated: true)
    }
}

protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}
