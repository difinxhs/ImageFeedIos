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
        
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in  // Изменил на правильный метод dataTask
            guard let self = self else { return }
            
            if let error = error {
                print("Error fetching profile image: \(error)")
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(ProfileImageServiceError.invalidRequest))
                return
            }
            
            do {
                print("decoding avatar started \(data)")
                let decoder = JSONDecoder()
                let userResult = try decoder.decode(UserResult.self, from: data)
                let result = UserImage(userResult: userResult)
                print("decode Image JSON success \(result)")
                if let avatarURL = result.small {
                    self.avatarURL = avatarURL  // Сохраняем URL маленького изображения
                    completion(.success(avatarURL))
                } else {
                    print("Failed to get small avatar URL")
                    completion(.failure(ProfileImageServiceError.invalidRequest))
                }
            } catch {
                print("Failed to decode ProfileImageJSON: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
}
