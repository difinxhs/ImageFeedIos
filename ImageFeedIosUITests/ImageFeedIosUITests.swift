import XCTest

final class ImageFeedUITests: XCTestCase {
    
    private let app = XCUIApplication()
    
    enum UserData {
        static let username = "8.kchayyy@gmail.com"
        static let password = "Empire7511"
        static let fullName = "Vladislav Belolipetskii"
        static let userName = "@difinxhs"
    }
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app.launchArguments = ["testMode"]
        app.launch()
    }
    
    func testAuth() throws {
        // тестируем сценарий авторизации
        let loginButton = app.buttons["Authenticate"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10))
        loginButton.tap()
        
        let webView = app.webViews["UnsplashWebView"]
        XCTAssertTrue(webView.waitForExistence(timeout: 10))
        
        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
        
        loginTextField.tap()
        loginTextField.typeText(UserData.username)
        webView.swipeUp()
        let doneButton = app.buttons["Done"]
        if doneButton.exists {
            doneButton.tap()
        }
        
        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))
        
        passwordTextField.tap()
        sleep(1)
        passwordTextField.typeText(UserData.password)
        webView.swipeUp()
        if doneButton.exists {
            doneButton.tap()
        }
        
        webView.buttons["Login"].tap()
        
        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        
    }
    
    func testFeed() throws {
        // тестируем сценарий ленты
        let tablesQuery = app.tables
        
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        XCTAssertTrue(cell.waitForExistence(timeout: 10))
        cell.swipeUp()
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        if cellToLike.buttons["LikeButtonOff"].waitForExistence(timeout: 5) {
            cellToLike.buttons["LikeButtonOff"].tap()
            XCTAssertTrue(cellToLike.buttons["LikeButtonOn"].waitForExistence(timeout: 5))
            cellToLike.buttons["LikeButtonOn"].tap()
            XCTAssertTrue(cellToLike.buttons["LikeButtonOff"].waitForExistence(timeout: 5))
        } else {
            XCTAssertTrue(cellToLike.buttons["LikeButtonOn"].waitForExistence(timeout: 5))
            cellToLike.buttons["LikeButtonOn"].tap()
            XCTAssertTrue(cellToLike.buttons["LikeButtonOff"].waitForExistence(timeout: 5))
            cellToLike.buttons["LikeButtonOff"].tap()
            XCTAssertTrue(cellToLike.buttons["LikeButtonOn"].waitForExistence(timeout: 5))
        }
        
        cellToLike.tap()
        let fullImage = app.scrollViews.images["full_image"]
        XCTAssertTrue(fullImage.waitForExistence(timeout: 30))
        sleep(1)
        
        fullImage.pinch(withScale: 3, velocity: 1)
        fullImage.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav_back_button"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        // тестируем сценарий профиля
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 10))
        profileTab.tap()
        
        XCTAssertTrue(app.staticTexts[UserData.fullName].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[UserData.userName].waitForExistence(timeout: 5))
        
        app.buttons["logoutButton"].tap()
        
        let yesButton = app.alerts.buttons["yesAlertButton"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 5))
        yesButton.tap()
        
        let loginButton = app.buttons["Authenticate"]
        XCTAssertTrue(loginButton.waitForExistence(timeout: 10))
    }
}
