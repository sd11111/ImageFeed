import Foundation


final class OAuth2Service {
    private let tokenStorage = OAuth2TokenStorage()
    static let shared = OAuth2Service()
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
        guard let request = makeOAuthTokenRequest(code: code) else {
            return
        }

        let task = URLSession.shared.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let response = try JSONDecoder().decode(OAuthTokenResponseBody.self, from: data
                    
                    )
                    self.tokenStorage.token = response.accessToken
                    completion(.success(response.accessToken))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }

        task.resume()
    }
}
