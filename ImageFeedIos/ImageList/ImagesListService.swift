import Foundation
import UIKit

enum ImagesListServiceError: Error {
    case invalidRequest
    case decodingError
}

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
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
    let regular: String
    let thumb: String
}

final class ImagesListService {
    private let storage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 1
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private func makePhotosURL() -> URLRequest? {
        var components = URLComponents(string: Constants.photoURL)
                components?.queryItems = [URLQueryItem(name: "page", value: String(lastLoadedPage))]
        
        guard let url = components?.url else {
            assertionFailure("[ImagesListService] Failed to create URL")
            return nil
        }
        
        guard let token = storage.token else {
            assertionFailure("[ImagesListService] Failed to get Token")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("[ImagesListService] makePhotoURL: \(request)")
        return request
    }
    
    func fetchPhotosNextPage() {
        
        guard let request = makePhotosURL() else {
            return
        }
        print("[ImagesListService] Ready to start fetching photos \(request)")
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let photoResults):
                            
                            self.photos.append(contentsOf: photoResults.map {
                                result in
                                    .init(
                                        id: result.id,
                                        size: CGSize(width: result.width, height: result.height),
                                        createdAt: self.parseDate(result.created_at),
                                        welcomeDescription: result.description,
                                        thumbImageURL: result.urls.thumb,
                                        largeImageURL: result.urls.regular,
                                        isLiked: result.liked_by_user
                                    )
                            })
                            self.lastLoadedPage += 1
                            
                            NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                            let didChangeNotification = Notification.Name(rawValue: "ImagesListProviderDidChange")
                            print("[ImagesListService] Success, photos count: \(photoResults.count)")
                            print("[ImagesListService] Notification sended. Successed to decode photos")
                        case .failure(let error):
                            print("[ImagesListService] Error fetching photos: \(error)")
                        }
                    }
                }
        
        task?.resume()
    }
    
    private func parseDate(_ dateString: String?) -> Date? {
        guard let dateString = dateString else { return nil }
        let dateFormatter = DateFormatter()
        return dateFormatter.date(from: dateString)
    }
}
