import Foundation
import UIKit

enum ImagesListServiceError: Error {
    case invalidRequest
    case decodingError
}

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    private let storage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private (set) var photos: [Photo] = []
    private var lastLoadedPage: Int = 1
    
    private let dateFormatter: ISO8601DateFormatter = {
           let formatter = ISO8601DateFormatter()
           return formatter
       }()
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    func cleanPhotosList() {
        photos = []
        print("[ImagesListService] cleanPhotosList? \(photos.isEmpty)")
    }
    
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
        
        print("[ImagesListService] makePhotoURL request: \(request)")
        return request
    }
    
    private func makePhotoLikesURL(for photo: Photo) -> URLRequest? {
        let photoId = photo.id
        
        guard let url = URL(string: "\(Constants.photoURL)/\(photoId)/like") else {
            assertionFailure("[ImagesListService] Failed to create LikesImageURL")
            return nil
        }
        
        print("[ImagesListService] makePhotoLikesURL url: \(url)")
        var request = URLRequest(url: url)
        
        if photo.isLiked == false {
            request.httpMethod = "POST"
            print("[ImagesListService] Photo liked")
        } else {
            request.httpMethod = "DELETE"
            print("[ImagesListService] Photo disliked")
        }
        
        guard let token = storage.token else {
            assertionFailure("[ImagesListService] Failed to get Token")
            return nil
        }
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("[ImagesListService] makePhotoURL request: \(request)")
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
                                        fullImageURL: result.urls.full,
                                        isLiked: result.liked_by_user
                                    )
                            })
                            self.lastLoadedPage += 1
                            
                            NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
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
            return dateFormatter.date(from: dateString)
        }
    
    func changeLike(photoId: String, isLike: Bool, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let index = photos.firstIndex(where: { $0.id == photoId }) else {
            print("[ImagesListService] Photo not found for id: \(photoId)")
            return
        }
        
        let photo = photos[index]
        
        guard let request = makePhotoLikesURL(for: photo) else {
            assertionFailure("[ImagesListService] Failed to create ProfileImageURL")
            return
        }
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }

                if let error = error {
                    print("[ImagesListService] Error liking photo: \(error)")
                    completion(.failure(error))
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, (httpResponse.statusCode == 200 || httpResponse.statusCode == 201) {
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            fullImageURL: photo.fullImageURL,
                            isLiked: !photo.isLiked
                        )
                        self.photos[index] = newPhoto
                        completion(.success(()))
                    }
                } else {
                    let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                    print("[ImagesListService] Error: Server returned status code \(statusCode)")
                    let serverError = NSError(domain: "", code: statusCode, userInfo: nil)
                    completion(.failure(serverError))
                }
            }
        }
        
        task.resume()
    }
}
