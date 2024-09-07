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
    private var lastLoadedPage: Int = 0
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    private func makePhotosURL(for page: Int, perPage: Int = 10, orderBy: String = "latest") -> URLRequest? {
        var components = URLComponents(string: Constants.photoURL)
        components?.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "order_by", value: orderBy)
        ]
        
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
        
        return request
    }
    
    func fetchPhotosNextPage(perPage: Int = 10, orderBy: String = "latest", completion: @escaping (Result<Void, Error>) -> Void) {
        guard task == nil else {
            print("[ImagesListService] Already loading, skip request")
            return
        }
        
        let nextPage = lastLoadedPage + 1
        
        guard let request = makePhotosURL(for: nextPage, perPage: perPage, orderBy: orderBy) else {
            completion(.failure(ImagesListServiceError.invalidRequest))
            return
        }
        
        task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
                    DispatchQueue.main.async {
                        guard let self = self else { return }
                        
                        switch result {
                        case .success(let photoResults):
                            let newPhotos = photoResults.map { result in
                                return Photo(
                                    id: result.id,
                                    size: CGSize(width: result.width, height: result.height),
                                    createdAt: self.parseDate(result.created_at),
                                    welcomeDescription: result.description,
                                    thumbImageURL: result.urls.thumb,
                                    largeImageURL: result.urls.regular,
                                    isLiked: result.liked_by_user
                                )
                            }
                            
                            self.photos.append(contentsOf: newPhotos)
                            self.lastLoadedPage = nextPage
                            
                            NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
                            
                            completion(.success(()))
                        case .failure(let error):
                            print("[ImagesListService] Error fetching photos: \(error)")
                            completion(.failure(error))
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
