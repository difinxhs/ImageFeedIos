import UIKit

protocol ProfilePresenterProtocol: AnyObject {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func avatarURL() -> URL?
    func logout()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    private let profileService = ProfileService.shared
    private let profileLogoutService = ProfileLogoutService.shared
    private let profileImageService = ProfileImageService.shared
    
    init() {
        print("[ProfilePresenter] Initialized")
    }
    
    func viewDidLoad() {
        guard let profile = profileService.profile else { return }
        view?.updateProfileDetails(profile: profile)
    }
    
    func avatarURL() -> URL? {
        guard let profileImageURL = ProfileImageService.shared.avatarURL else {
            print("[ProfilePresenter avatarURL] avatarURL is nil")
            return nil
        }
        guard let url = URL(string: profileImageURL) else {
            print("[ProfilePresenter avatarURL] Failed to create URL from: \(profileImageURL)")
            return nil
        }
        print("[ProfilePresenter avatarURL] url: \(url)")
        return url
    }
    
    func logout() {
        profileLogoutService.logout()
    }
}
