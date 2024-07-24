import UIKit

final class ProfileViewController: UIViewController {
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userTag: UILabel!
    @IBOutlet weak var userDescription: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    
    private var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeLayout()
    }
    
    //MARK: Layout
    private func makeLayout() {
        
        //ProfileImage
        let profileImage = UIImage(named: "UserPic")
        let imageView = UIImageView(image: profileImage)
        imageView.tintColor = .gray
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        //UserName
        let userName = UILabel()
        userName.text = "Екатерина Новикова"
        userName.textColor = .ypWhite
        userName.font = UIFont.systemFont(ofSize: 23, weight: UIFont.Weight(rawValue: 400))
        userName.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userName)
        userName.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        userName.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8).isActive = true
        self.userName = userName
        
        //UserTag
        let userTag = UILabel()
        userTag.text = "@ekaterina_nov"
        userTag.textColor = .ypGray
        userTag.font = UIFont.systemFont(ofSize: 13)
        userTag.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userTag)
        userTag.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        userTag.topAnchor.constraint(equalTo: userName.bottomAnchor, constant: 8).isActive = true
        self.userTag = userTag
        
        //UserDescription
        let userDescription = UILabel()
        userDescription.text = "Hello World!"
        userDescription.textColor = .ypWhite
        userDescription.font = UIFont.systemFont(ofSize: 13)
        userDescription.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(userDescription)
        userDescription.leadingAnchor.constraint(equalTo: imageView.leadingAnchor).isActive = true
        userDescription.topAnchor.constraint(equalTo: userTag.bottomAnchor, constant: 8).isActive = true
        self.userTag = userTag
        
        //ExitButton
        let exitButton = UIButton.systemButton(
            with: UIImage(named: "ExitButton")!,
            target: self,
            action: #selector(Self.exitButtonDidTap)
        )
        exitButton.tintColor = .red
        exitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exitButton)
        exitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20).isActive = true
        exitButton.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
    }
    
    
    @objc func exitButtonDidTap(_ sender: Any) {
    }
}
