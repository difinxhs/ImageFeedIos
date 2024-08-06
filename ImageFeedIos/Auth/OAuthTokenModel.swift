import Foundation

struct OAuthToken: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int
}
