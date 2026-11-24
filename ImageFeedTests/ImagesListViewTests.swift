@testable import ImageFeed
import XCTest

final class ImagesListViewTests: XCTestCase {
    @MainActor
    func testViewControllerCallsViewDidLoad() {
        // given
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController"
        ) as! ImagesListViewController

        let presenter = ImagesListPresenterSpy()
        viewController.configure(presenter)

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}

final class ImagesListPresenterSpy: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }

    func fetchPhotosNextPage() {
    }

    func changeLike(
        photoId: String,
        isLike: Bool,
        completion: @escaping (Result<Void, Error>) -> Void
    ) {
    }
}
