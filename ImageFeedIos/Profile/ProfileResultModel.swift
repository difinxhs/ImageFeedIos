import Foundation

struct ProfileResult: Codable {
    let username: String
    let first_name: String
    let last_name: String?
    let bio: String?
}
