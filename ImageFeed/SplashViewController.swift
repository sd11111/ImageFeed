//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Semen Davydov on 07.10.2026.
//

import UIKit

final class SplashViewController : UIViewController, AuthViewControllerDelegate {

    private let storage = OAuth2TokenStorage()
    private let showImageFeedScreenSegueIdentifier = "ShowImageFeedScreen"
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if storage.token != nil {
            switchToTabBarController()
        } else {
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
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
        switchToTabBarController()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Вызван prepare: \(String(describing: segue.identifier))")

        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers.first as? AuthViewController
            else {
                print("Не удалось найти AuthViewController")
                assertionFailure("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)")
                return
            }

            viewController.delegate = self
            print("Делегат назначен: \(String(describing: viewController.delegate))")
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}
