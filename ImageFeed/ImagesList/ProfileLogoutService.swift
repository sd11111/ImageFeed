import Foundation
import WebKit

@MainActor
final class ProfileLogoutService {
    static let shared = ProfileLogoutService()

    private init() {}

    func logout(
        completion: @escaping @MainActor @Sendable () -> Void
    ) {
        OAuth2Service.shared.reset()
        OAuth2TokenStorage().token = nil

        ProfileService.shared.reset()
        ProfileImageService.shared.reset()
        ImagesListService.shared.reset()

        cleanCookies(completion: completion)
    }

    private func cleanCookies(
        completion: @escaping @MainActor @Sendable () -> Void
    ) {
        HTTPCookieStorage.shared.removeCookies(
            since: Date.distantPast
        )

        let dataStore = WKWebsiteDataStore.default()
        let dataTypes = WKWebsiteDataStore.allWebsiteDataTypes()

        dataStore.fetchDataRecords(ofTypes: dataTypes) { records in
            dataStore.removeData(
                ofTypes: dataTypes,
                for: records,
                completionHandler: completion
            )
        }
    }
}
