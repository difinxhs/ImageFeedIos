import UIKit

final class SplashViewController: UIViewController {
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    
    private let oauth2Service = OAuth2Service.shared
    private let oauth2TokenStorage = OAuth2TokenStorage()
    
    var profile = ProfileService.shared.profile
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLogo()
        view.backgroundColor = UIColor(named: "YP Black")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = oauth2TokenStorage.token {
            print("didAppear - ready to load profile")
            fetchProfile(token: token) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success:
                    print("Profile successfully fetched")
                    self.fetchProfileImage(token: token)
                case .failure(let error):
                    print("Failed to fetch profile: \(error)")
                }
            }
        } else {
            // Переход на экран авторизации
            let storyboard = UIStoryboard(name: "Main", bundle: .main)
            guard let authViewController = storyboard.instantiateViewController(
                withIdentifier: "AuthViewController"
            ) as? AuthViewController else {
                fatalError("AuthViewController не найден в Storyboard")
            }
            authViewController.delegate = self
            authViewController.modalPresentationStyle = .fullScreen
            present(authViewController, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    private func setupLogo() {
        let logo = UIImage(named: "UnsplashLogo")
        let imageView = UIImageView(image: logo)
        imageView.tintColor = UIColor(named: "YP White")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
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
                print("Proebal token")
                break
            }
        }
    }
    
    private func fetchProfile(token: String, completion: @escaping (Result<Void, Error>) -> Void) {
        UIBlockingProgressHUD.show()
        print("loading profile - SplashScreen")
        ProfileService.shared.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case .success(let profile):
                print("splashscreen fetchProfile working: \(profile)")
                self.profile = profile
                completion(.success(()))
            case .failure(let error):
                print("Failed to fetch profile: \(error)")
                completion(.failure(error))
            }
        }
    }
    
    
    private func fetchProfileImage(token: String) {
        print("loading profileImage - SplashScreen")
        let username = ProfileService.shared.giveMeUsername()
        print("fetchProfileImage- SplashScreen username: \(username)")
        
        ProfileImageService.shared.fetchProfileImageURL(username: username) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let avatarURL):
                print("splashscreen fetchProfileImage working: \(avatarURL)")
                self.switchToTabBarController()
            case .failure(let error):
                print("Failed to fetch profile image: \(error)")
            }
        }
    }
}
