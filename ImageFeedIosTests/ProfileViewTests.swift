import XCTest
import UIKit
@testable import ImageFeedIos

final class ProfileViewControllerTests: XCTestCase {
    
    var viewController: ProfileViewController!
    var presenterSpy: ProfilePresenterSpy!
    
    override func setUpWithError() throws {
        super.setUp()
        
        viewController = ProfileViewController()
        presenterSpy = ProfilePresenterSpy()
        viewController.presenter = presenterSpy
        presenterSpy.view = viewController as? any ProfileViewControllerProtocol
        viewController.loadViewIfNeeded()
    }
    
    override func tearDownWithError() throws {
        viewController = nil
        presenterSpy = nil
        super.tearDown()
    }
    
    func testUpdateProfileDetails_WhenCalled_ShouldUpdateLabels() {
        let profileResult = ProfileResult(username: "@testuser", first_name: "Test", last_name: "User", bio: "This is a test bio")
        let profile = Profile(profileResult: profileResult)
        viewController.updateProfileDetails(profile: profile)
        XCTAssertEqual(viewController.userTag.text, profile.username)
        XCTAssertEqual(viewController.userName.text, profile.name)
        XCTAssertEqual(viewController.userDescription.text, profile.bio)
    }
    
    func testAvatarUpdateCalled() {
            let profileViewController = ProfileViewController()
            let profilePresenterSpy = ProfilePresenterSpy()
            profilePresenterSpy.view = profileViewController
            profileViewController.presenter = profilePresenterSpy
            
            _ = profileViewController.view
            XCTAssertTrue(profilePresenterSpy.updateAvatarCalled)
        }
}

final class ProfilePresenterSpy: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?

    private(set) var didCallViewDidLoad = false
    private(set) var updateAvatarCalled = false

    var stubbedProfile: Profile?
    var stubbedAvatarURL: URL?

    func viewDidLoad() {
        didCallViewDidLoad = true
//        if let profile = stubbedProfile {
//            view?.updateProfile(username: profile.username, name: profile.name, bio: profile.bio)
//        }
    }
    
    func avatarURL() -> URL? {
        updateAvatarCalled = true
        return nil
    }

    func logout() {
    }
}
