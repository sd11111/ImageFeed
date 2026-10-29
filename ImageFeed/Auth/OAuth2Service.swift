import Foundation
import SwiftKeychainWrapper

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {

    static let shared = OAuth2Service()

    private var task: URLSessionTask?
    private var lastCode: String?
    private var currentRequestID: UUID?

    private(set) var authToken: String? {
        get {
            KeychainWrapper.standard.string(forKey: "authToken")
        }
        set {
            if let newValue {
                KeychainWrapper.standard.set(newValue, forKey: "authToken")
            } else {
                KeychainWrapper.standard.removeObject(forKey: "authToken")
            }
        }
    }

    private init() { }

    private func makeOAuthTokenRequest(code: String) -> URLRequest? {

        guard var urlComponents = URLComponents(string: "https://unsplash.com/oauth/token") else {
            print("Ошибка - не удалось создать URLComponents для OAuth token")
            return nil
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code"),
        ]

        guard let authTokenUrl = urlComponents.url else {
            print("Ошибка - не удалось создать URL для OAuth token")
            return nil
        }

        var request = URLRequest(url: authTokenUrl)
        request.httpMethod = "POST"
        return request
    }
    
    
    

    func fetchOAuthToken(
        code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        assert(Thread.isMainThread)

        if task != nil {
            if lastCode != code {
                task?.cancel()
            } else {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        } else {
            if lastCode == code {
                completion(.failure(AuthServiceError.invalidRequest))
                return
            }
        }

        lastCode = code

        guard let request = makeOAuthTokenRequest(code: code) else {
            lastCode = nil
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let requestID = UUID()
        currentRequestID = requestID

        let task = URLSession.shared.objectTask(for: request) { [weak self] (result: Result<OAuthTokenResponseBody, Error>) in

            DispatchQueue.main.async {
                guard let self else { return }
                guard self.currentRequestID == requestID else { return }

                self.currentRequestID = nil
                self.task = nil
                self.lastCode = nil

                switch result {

                case .success(let response):
                    self.authToken = response.accessToken
                    completion(.success(response.accessToken))

                case .failure(let error):
                    print("[OAuth2Service.fetchOAuthToken]: \(error.localizedDescription)")
                    completion(.failure(error))
                }
            }
        }

        self.task = task
        task.resume()
    }

    private struct OAuthTokenResponseBody: Codable {
        let accessToken: String

        enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
        }
    }
}

