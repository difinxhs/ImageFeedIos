import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let fullImageURL: String
    let isLiked: Bool
}

struct PhotoResult: Decodable {
    let id: String
    let created_at: String?
    let width: Int
    let height: Int
    let description: String?
    let likes: Int
    let liked_by_user: Bool
    let urls: UrlsResult
}

struct UrlsResult: Decodable {
    let full: String
    let thumb: String
}
