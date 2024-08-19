import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"

    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    var profile = ProfileService.shared.profile

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if let token = oauth2TokenStorage.token {
            print("didAppear - ready to load profile")
            fetchProfile(token: token)
        } else {
            // Show Auth Screen
            performSegue(withIdentifier: showAuthenticationScreenSegueIdentifier, sender: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }

    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showAuthenticationScreenSegueIdentifier {
            guard
                let navigationController = segue.destination as? UINavigationController,
                let viewController = navigationController.viewControllers[0] as? AuthViewController
            else { fatalError("Failed to prepare for \(showAuthenticationScreenSegueIdentifier)") }
            viewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func authViewController(_ vc: AuthViewController, didAuthenticateWithCode code: String) {
        dismiss(animated: true) { [weak self] in
            guard let self else { return }
            self.fetchOAuthToken(code)
        }
    }
    
    private func fetchOAuthToken(_ code: String) {
        oauth2Service.fetchOAuthToken(code: code) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure:
                // TODO [Sprint 11]
                break
            }
        }
    }
    
//    private func didAuthenticate(_ vc: AuthViewController) {
//        vc.dismiss(animated: true)
//        
//        guard let token = oauth2TokenStorage.token else {
//            return
//        }
//        print("didAuthenticate - true")
//        fetchProfile(token: token)
//    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        print("loading profile - SplashScreen")
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()

            guard let self = self else { return }

            switch result {
            case .success:
                print("splashscreen fetchProfile working \(result)")
                self.switchToTabBarController()

            case .failure:
                // TODO: Покажите ошибку получения профиля
                break
            }
        }
    }
    
    private func fetchProfileImage(token: String) {
        //UIBlockingProgressHUD.show()
        print("loading profileImage - SplashScreen")
        guard let username = ProfileService.shared.profile?.username else { return }
        
        
        ProfileImageService.shared.fetchProfileImageURL(username: username) { result in
           // UIBlockingProgressHUD.dismiss()
            
//            guard let self = self else { return }
            
            switch result {
            case .success:
                print("splashscreen fetchProfileImage working \(result)")
                self.switchToTabBarController()

            case .failure:
                // TODO: Покажите ошибку получения изображения профиля
                break
            }
            
        }
//        ProfileService.shared.fetchProfile(token) { [weak self] result in
//            UIBlockingProgressHUD.dismiss()
//
//            guard let self = self else { return }
//
//            switch result {
//            case .success:
//                print("splashscreen fetchProfile working \(result)")
//                self.switchToTabBarController()
//
//            case .failure:
//                // TODO: Покажите ошибку получения профиля
//                break
//            }
//        }
    }
    
}
