import UIKit
import SwiftKeychainWrapper
import Kingfisher

protocol ProfileViewControllerProtocol: AnyObject {
    func updateProfileDetails(profile: Profile)
    func updateAvatar(url: URL?)
}

class ProfileViewController: UIViewController, ProfileViewControllerProtocol {
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userTag: UILabel!
    @IBOutlet weak var userDescription: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    var presenter: ProfilePresenterProtocol!
    
    private var label: UILabel?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileImage()
        setupUserName()
        setupUserTag()
        setupUserDescription()
        setupExitButton()
        
        if presenter == nil {
            presenter = ProfilePresenter()
            presenter.view = self
        }
        
        print("[ProfileViewController] presenter is \(presenter == nil ? "nil" : "set")")
        
        view.backgroundColor = UIColor(named: "YP Black")
        
        
        if  let profile = ProfileService.shared.profile {
            print("[ProfileViewController] loading Profile")
            updateProfileDetails(profile: profile)
        } else {
            print("[ProfileViewController] can't load Profile")
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                print("[ProfileViewController] profileImageServiceObserver is working")
                self.updateAvatar(url: presenter?.avatarURL())
            }
        if let avatarURL = presenter?.avatarURL() {
            updateAvatar(url: avatarURL)
        } else {
            print("[ProfileViewController] avatarURL is nil")
        }
    }
    
    func updateProfileDetails(profile: Profile) {
        print("[ProfileViewController] func updateProfile is working")
        userTag.text = profile.username
        userName.text = profile.name
        userDescription.text = profile.bio
    }
    
    func updateAvatar(url: URL?) {
        guard let url else {
            debugPrint("[ProfileViewController updateAvatar] No avatar url")
            return
        }
        let processor = RoundCornerImageProcessor(cornerRadius: 80)
        userPic.kf.indicatorType = IndicatorType.activity
        userPic.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholder"),
            options: [
                .processor(processor),
                .cacheSerializer(FormatIndicatedCacheSerializer.png)
            ]
        ) { _ in debugPrint("Avatar installed") }
    }
    
    
    //MARK: Layout
    
    private func setupProfileImage() {
        let profileImage = UIImage(named: "UserPic")
        let imageView = UIImageView(image: profileImage)
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70)
        ])
        self.userPic = imageView
    }
    
    private func setupUserName() {
        let userName = UILabel()
        userName.text = "Екатерина Новикова"
        userName.textColor = .ypWhite
        userName.font = UIFont.systemFont(ofSize: 23, weight: UIFont.Weight(rawValue: 400))
        userName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userName)
        NSLayoutConstraint.activate([
            userName.leadingAnchor.constraint(equalTo: userPic.leadingAnchor),
            userName.topAnchor.constraint(equalTo: userPic.bottomAnchor, constant: 8)
        ])
        self.userName = userName
    }
    
    private func setupUserTag() {
        let userTag = UILabel()
        userTag.text = "@ekaterina_nov"
        userTag.textColor = .ypGray
        userTag.font = UIFont.systemFont(ofSize: 13)
        userTag.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userTag)
        NSLayoutConstraint.activate([
            userTag.leadingAnchor.constraint(equalTo: userPic.leadingAnchor),
            userTag.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8)
        ])
        self.userTag = userTag
    }
    
    private func setupUserDescription() {
        let userDescription = UILabel()
        userDescription.text = "Hello World!"
        userDescription.textColor = .ypWhite
        userDescription.font = UIFont.systemFont(ofSize: 13)
        userDescription.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userDescription)
        NSLayoutConstraint.activate([
            userDescription.leadingAnchor.constraint(equalTo: userPic.leadingAnchor),
            userDescription.topAnchor.constraint(equalTo: userTag.bottomAnchor, constant: 8)
        ])
        self.userDescription = userDescription
    }
    
    private func setupExitButton() {
        let exitButton = UIButton.systemButton(
            with: UIImage(named: "ExitButton")!,
            target: self,
            action: #selector(Self.exitButtonDidTap)
        )
        exitButton.tintColor = .red
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        NSLayoutConstraint.activate([
            exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            exitButton.centerYAnchor.constraint(equalTo: userPic.centerYAnchor)
        ])
        self.exitButton = exitButton
    }
    
    @objc private func exitButtonDidTap(_ sender: Any) {
        let alert = UIAlertController(title: "Пока, пока!",
                                      message: "Уверены что хотите выйти?",
                                      preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Нет", style: .default) { _ in
            alert.dismiss(animated: true)
        }
        let action = UIAlertAction(title: "Да", style: .default) { _ in
            ProfileLogoutService.shared.logout()
            guard let window = UIApplication.shared.windows.first else {
                assertionFailure("Invalid window configuration")
                return
            }
            window.rootViewController = SplashViewController()
            window.makeKeyAndVisible()
        }
        alert.addAction(action)
        alert.addAction(dismiss)
        self.present(alert, animated: true, completion: nil)
    }
}
