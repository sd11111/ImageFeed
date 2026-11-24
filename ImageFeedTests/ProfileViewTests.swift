@testable import ImageFeed
import XCTest

final class ProfileViewTests: XCTestCase {
    @MainActor
    func testViewControllerCallsViewDidLoad() {
        // given
        let viewController = ProfileViewController()
        let presenter = ProfilePresenterSpy()
        viewController.configure(presenter)

        // when
        _ = viewController.view

        // then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false

    func viewDidLoad() {
        viewDidLoadCalled = true
    }
}
