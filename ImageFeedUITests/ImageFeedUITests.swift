import XCTest

final class ImageFeedUITests: XCTestCase {
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launch()
    }

    func testAuth() throws {
        let authenticateButton = app.buttons["Authenticate"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 15))
        authenticateButton.tap()

        let webView = app.webViews["UnsplashWebView"]

        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView
            .descendants(matching: .textField)
            .element

        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))

        loginTextField.tap()
        loginTextField.typeText("")
        webView.swipeUp()

        let passwordTextField = webView
            .descendants(matching: .secureTextField)
            .element

        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))

        passwordTextField.tap()
        passwordTextField.typeText("")
        webView.swipeUp()

        webView.buttons["Login"].tap()

        let tablesQuery = app.tables
        let cell = tablesQuery
            .children(matching: .cell)
            .element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: 5))
    }

    func testFeed() throws {
        let table = app.tables.element
        XCTAssertTrue(table.waitForExistence(timeout: 15))

        let firstCell = table
            .children(matching: .cell)
            .element(boundBy: 0)

        XCTAssertTrue(firstCell.waitForExistence(timeout: 15))
        firstCell.swipeUp()

        sleep(2)

        let cellToLike = table
            .children(matching: .cell)
            .element(boundBy: 1)

        XCTAssertTrue(cellToLike.waitForExistence(timeout: 10))

        let likeButtonOff = cellToLike.buttons["like button off"]
        XCTAssertTrue(likeButtonOff.waitForExistence(timeout: 5))
        likeButtonOff.tap()

        sleep(2)

        let updatedCell = table
            .children(matching: .cell)
            .element(boundBy: 1)

        let likeButtonOn = updatedCell.buttons["like button on"]
        XCTAssertTrue(likeButtonOn.waitForExistence(timeout: 5))
        likeButtonOn.tap()

        sleep(2)

        let cellToOpen = table
            .children(matching: .cell)
            .element(boundBy: 1)

        XCTAssertTrue(cellToOpen.waitForExistence(timeout: 5))
        cellToOpen.tap()

        let image = app.scrollViews.images.element(boundBy: 0)
        XCTAssertTrue(image.waitForExistence(timeout: 15))

        image.pinch(withScale: 3, velocity: 1)
        image.pinch(withScale: 0.5, velocity: -1)

        let backButton = app.buttons["nav back button white"]
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        backButton.tap()

        XCTAssertTrue(table.waitForExistence(timeout: 5))
    }

    func testProfile() throws {
        let table = app.tables.element
        XCTAssertTrue(table.waitForExistence(timeout: 15))

        app.tabBars.buttons.element(boundBy: 1).tap()

        let nameLabel = app.staticTexts["ProfileName"]
        let usernameLabel = app.staticTexts["ProfileUsername"]

        XCTAssertTrue(nameLabel.waitForExistence(timeout: 5))
        XCTAssertTrue(usernameLabel.waitForExistence(timeout: 5))
        XCTAssertFalse(nameLabel.label.isEmpty)
        XCTAssertFalse(usernameLabel.label.isEmpty)

        let logoutButton = app.buttons["logout button"]
        XCTAssertTrue(logoutButton.waitForExistence(timeout: 5))
        logoutButton.tap()

        let alert = app.alerts["Выход из аккаунта"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))

        alert.buttons["Выйти"].tap()

        let authenticateButton = app.buttons["Authenticate"]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 15))
    }
}
