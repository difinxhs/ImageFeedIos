import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet private weak var userPic: UIImageView!
    @IBOutlet private weak var userName: UILabel!
    @IBOutlet private weak var userTag: UILabel!
    @IBOutlet private weak var userDescription: UILabel!
    @IBOutlet private weak var exitButton: UIButton!
    
    private var label: UILabel?
    
    override func viewDidLoad() {
           super.viewDidLoad()
           
           setupProfileImage()
           setupUserName()
           setupUserTag()
           setupUserDescription()
           setupExitButton()
        
        guard let token = OAuth2TokenStorage().token else {
               print("No token found")
               return
           }
        
        let profileService = ProfileService()
        
        profileService.fetchProfile(token) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let profile):
                    self.userTag.text = profile.username
                    self.userName.text = profile.name
                    self.userDescription.text = profile.bio
                    
                case .failure(let error):
                    print("Error fetching profile: \(error)")
                }
            }
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
           //userName.text = "Екатерина Новикова"
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
           //userTag.text = "@ekaterina_nov"
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
           //userDescription.text = "Hello World!"
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
