import UIKit

enum ProfileImageServiceError: Error {
    case invalidRequest
}

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    private let storage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    private var username = ProfileService.shared.profile?.username
    
    private(set) var avatarURL: String?
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    struct UserResult: Codable {
        let profile_image: [String: String]  // Изменил тип на словарь для получения разных размеров изображения
    }
    
    struct UserImage {
        let small: String?  // Указал нужный размер изображения
        
        init(userResult: UserResult) {
            self.small = userResult.profile_image["small"]  // Достаем только маленькое изображение
        }
    }
    
    private func makeAvatarURL() -> URLRequest? {
        guard let username = username else { return nil }
        
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        guard let url = URL(
            string: "/users/\(username)",  // Исправил URL, убрал "profile_image/small", так как это часть ответа API
            relativeTo: baseURL
        ) else {
            assertionFailure("Failed to create ImageURL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        guard let token = storage.token else {
            assertionFailure("Failed to get ProfileImageToken")
            return nil
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("request makeAvatarURL: \(request)")
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard username == username else {
            completion(.failure(ProfileImageServiceError.invalidRequest))  // Исправил ошибку, неверный enum был использован
            return
        }
        
        task?.cancel()
        
        guard let request = makeAvatarURL() else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        
        let task = urlSession.objectTask(for: request) { (result: Result<UserResult, Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let userResult):
                        let userImage = UserImage(userResult: userResult)
                        self.avatarURL = userImage.small
                        if let avatarURL = self.avatarURL {
                            completion(.success(avatarURL))
                        } else {
                            completion(.failure(ProfileImageServiceError.invalidRequest))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        
        task.resume()
    }
}
