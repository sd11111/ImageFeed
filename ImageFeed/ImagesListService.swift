import Foundation
import CoreGraphics

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: String
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool

    private enum CodingKeys: String, CodingKey {
        case id
        case width
        case height
        case description
        case urls
        case createdAt = "created_at"
        case likedByUser = "liked_by_user"
    }
}

struct UrlsResult: Decodable {
    let small: String
    let full: String
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
}

final class ImagesListService {
    static let shared = ImagesListService()
    static let didChangeNotification = Notification.Name(
        rawValue: "ImagesListServiceDidChange"
    )

    private(set) var photos: [Photo] = []
    private var sessionID = UUID()
    private var task: URLSessionTask?
    private var lastLoadedPage = 0
    private let dateFormatter = ISO8601DateFormatter()

    func fetchPhotosNextPage() {
        assert(Thread.isMainThread)

        guard task == nil else {
            return
        }

        guard let token = OAuth2Service.shared.authToken else {
            return
        }

        let nextPage = lastLoadedPage + 1

        guard let url = URL(
            string: "https://api.unsplash.com/photos?page=\(nextPage)"
        ) else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        let sessionID = self.sessionID
        
        let task = URLSession.shared.objectTask(for: request) {
            [weak self] (result: Result<[PhotoResult], Error>) in

            guard self?.sessionID == sessionID else {
                return
            }
            
            guard let self else { return }

            self.task = nil

            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { photoResult in
                    Photo(
                        id: photoResult.id,
                        size: CGSize(
                            width: CGFloat(photoResult.width),
                            height: CGFloat(photoResult.height)
                        ),
                        createdAt: self.dateFormatter.date(
                            from: photoResult.createdAt
                        ),
                        welcomeDescription: photoResult.description,
                        thumbImageURL: photoResult.urls.small,
                        largeImageURL: photoResult.urls.full,
                        isLiked: photoResult.likedByUser
                    )
                }

                self.photos.append(contentsOf: newPhotos)
                self.lastLoadedPage = nextPage

                NotificationCenter.default.post(
                    name: Self.didChangeNotification,
                    object: self
                )

            case .failure(let error):
                print(
                    "[ImagesListService.fetchPhotosNextPage]: " +
                    "\(type(of: error)) - \(error); page=\(nextPage)"
                )
            }
        }

        self.task = task
        task.resume()
    }
    
    func reset() {
        sessionID = UUID()
        task?.cancel()
        task = nil
        photos = []
        lastLoadedPage = 0
    }
    
    func changeLike(
        photoId: String,
        isLike: Bool,
        _ completion: @escaping (Result<Void, Error>) -> Void
    ) {
        assert(Thread.isMainThread)

        guard let token = OAuth2Service.shared.authToken else {
            completion(.failure(URLError(.userAuthenticationRequired)))
            return
        }

        guard let url = URL(
            string: "https://api.unsplash.com/photos/\(photoId)/like"
        ) else {
            completion(.failure(NetworkError.invalidRequest))
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "POST" : "DELETE"
        request.setValue(
            "Bearer \(token)",
            forHTTPHeaderField: "Authorization"
        )

        let sessionID = self.sessionID
        
        let task = URLSession.shared.data(for: request) {
            [weak self] result in
            
            guard self?.sessionID == sessionID else {
                return
            }
            
            guard let self else {
                completion(.failure(URLError(.cancelled)))
                return
            }

            switch result {
            case .success:
                guard let index = self.photos.firstIndex(
                    where: { $0.id == photoId }
                ) else {
                    completion(.failure(NetworkError.invalidRequest))
                    return
                }

                let photo = self.photos[index]

                let newPhoto = Photo(
                    id: photo.id,
                    size: photo.size,
                    createdAt: photo.createdAt,
                    welcomeDescription: photo.welcomeDescription,
                    thumbImageURL: photo.thumbImageURL,
                    largeImageURL: photo.largeImageURL,
                    isLiked: !photo.isLiked
                )

                self.photos[index] = newPhoto
                completion(.success(()))

            case .failure(let error):
                print(
                    "[ImagesListService.changeLike]: " +
                    "\(type(of: error)) - \(error); " +
                    "photoId=\(photoId), isLike=\(isLike)"
                )

                completion(.failure(error))
            }
        }

        task.resume()
    }
}
