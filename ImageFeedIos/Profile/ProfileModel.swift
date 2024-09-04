import Foundation

struct Profile {
    let username: String
    let name: String
    let bio: String
    
    init(profileResult: ProfileResult) {
        self.username = "@" + profileResult.username
        self.name = profileResult.first_name + " " + (profileResult.last_name ?? "")
        self.bio = profileResult.bio ?? ""
    }
}
