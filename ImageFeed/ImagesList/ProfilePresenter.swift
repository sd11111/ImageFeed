import Foundation

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(profile: Profile)
    func updateAvatar()
}

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    private let profileService = ProfileService.shared
    private var profileImageServiceObserver: NSObjectProtocol?

    func viewDidLoad() {
        if let profile = profileService.profile {
            view?.updateProfileDetails(profile: profile)
        }

        profileImageServiceObserver = NotificationCenter.default.addObserver(
            forName: ProfileImageService.didChangeNotification,
            object: ProfileImageService.shared,
            queue: .main
        ) { [weak self] _ in
            self?.updateAvatar()
        }

        updateAvatar()
    }

    private func updateAvatar() {
        view?.updateAvatar()
    }

    deinit {
        if let observer = profileImageServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
