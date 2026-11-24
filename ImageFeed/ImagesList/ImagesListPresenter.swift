import Foundation

protocol ImagesListViewControllerProtocol: AnyObject {
    func updateTableViewAnimated(oldCount: Int, newCount: Int)
}

protocol ImagesListPresenterProtocol: AnyObject {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get }

    func viewDidLoad()
    func fetchPhotosNextPage()

    func changeLike(
        photoId: String,
        isLike: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    )
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?

    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?

    private(set) var photos: [Photo] = []

    func viewDidLoad() {
        imagesListServiceObserver = NotificationCenter.default.addObserver(
            forName: ImagesListService.didChangeNotification,
            object: imagesListService,
            queue: .main
        ) { [weak self] _ in
            self?.updateTableViewAnimated()
        }

        fetchPhotosNextPage()
    }

    func fetchPhotosNextPage() {
        imagesListService.fetchPhotosNextPage()
    }

    func changeLike(
        photoId: String,
        isLike: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
        imagesListService.changeLike(
            photoId: photoId,
            isLike: isLike
        ) { [weak self] result in
            guard let self else { return }

            if case .success = result {
                self.photos = self.imagesListService.photos
            }

            completion(result)
        }
    }

    private func updateTableViewAnimated() {
        let oldCount = photos.count
        photos = imagesListService.photos
        let newCount = photos.count

        view?.updateTableViewAnimated(
            oldCount: oldCount,
            newCount: newCount
        )
    }

    deinit {
        if let observer = imagesListServiceObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
