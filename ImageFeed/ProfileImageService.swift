
import Foundation
import SwiftKeychainWrapper

struct ProfileImage: Codable {
    let small: String
    let medium: String
    let large: String

    private enum CodingKeys: String, CodingKey {
        case small
        case medium
        case large
    }
}

struct UserResult: Codable {
    let profileImage: ProfileImage

    private enum CodingKeys: String, CodingKey {
        case profileImage = "profile_image"
    }
}

final class ProfileImageService {

    // Синглтон
    static let shared = ProfileImageService()

    private init() {}

    // Приватное свойство для хранения URL аватарки
    private(set) var avatarURL: String?

    private var task: URLSessionTask?

    static let didChangeNotification = Notification.Name(
        rawValue: "ProfileImageProviderDidChange"
    )

    // Метод для получения аватарки по имени пользователя
    func fetchProfileImageURL(username: String, completion: @escaping (Result<String, Error>) -> Void) {

        task?.cancel()

        guard let token = KeychainWrapper.standard.string(forKey: "authToken") else {
            completion(.failure(NSError(
                domain: "ProfileImageService",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Authorization token missing"]
            )))
            return
        }

        guard let request = makeProfileImageRequest(username: username, token: token) else {
            completion(.failure(URLError(.badURL)))
            return
        }

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in

            guard let self else { return }

            switch result {

            case .success(let userResult):
                let profileImageURL = userResult.profileImage.small

                self.avatarURL = profileImageURL

                completion(.success(profileImageURL))

                NotificationCenter.default.post(
                    name: ProfileImageService.didChangeNotification,
                    object: self,
                    userInfo: ["URL": profileImageURL]
                )

            case .failure(let error):
                print("[ProfileImageService.fetchProfileImageURL]: \(error.localizedDescription)")
                completion(.failure(error))
            }

            self.task = nil
        }

        self.task = task
        task.resume()
    }

    private func makeProfileImageRequest(username: String, token: String) -> URLRequest? {

        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            return nil
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
}
