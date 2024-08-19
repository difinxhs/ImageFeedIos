import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet private weak var userPic: UIImageView!
    @IBOutlet  weak var userName: UILabel!
    @IBOutlet  weak var userTag: UILabel!
    @IBOutlet  weak var userDescription: UILabel!
    @IBOutlet private weak var exitButton: UIButton!
    
    private var label: UILabel?
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupProfileImage()
        setupUserName()
        setupUserTag()
        setupUserDescription()
        setupExitButton()
        
        
        if  let profile = ProfileService.shared.profile {
            print("loading Profile")
            updateProfileDetails(profile: profile)
        } else {
            print("can't load Profile")
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        updateAvatar()
    }
    
    private func updateProfileDetails(profile: ProfileService.Profile) {
        print("func updateProfile is working")
        userTag.text = profile.username
        userName.text = profile.name
        userDescription.text = profile.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else { return }
        //TODO: обновить аватар используя Kingfisher
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
    
    @objc func exitButtonDidTap(_ sender: Any) {
    }
}
