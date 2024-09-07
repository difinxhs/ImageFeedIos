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
    private var username = ProfileService.shared.profile?.username
    
    private(set) var avatarURL: String?
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    
    //TODO: вынести модели в отдельные файлы
    struct UserResult: Codable {
        let profile_image: [String: String]
    }
    
    struct UserImage {
        let small: String?
        
        init(userResult: UserResult) {
            self.small = userResult.profile_image["small"]
        }
    }
    
    private func makeAvatarURL() -> URLRequest? {
        
        let username = ProfileService.shared.giveMeUsername()
        
        guard let url = URL(string: "\(Constants.usersURL)\(username)") else {
            assertionFailure("[ProfileImageService] Failed to create ProfileImageURL")
            return nil
        }
        print("[ProfileImageService] makeAvatarURL url: \(url)")
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        guard let token = storage.token else {
            assertionFailure("[ProfileImageService] Failed to get ProfileImageToken")
            return nil
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("[ProfileImageService] makeAvatarURL request: \(request)")
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        print("[ProfileImageService] fetchProfileImageURL username: \(username)")
        task?.cancel()
        
        guard
            let request = makeAvatarURL()
        else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        
        let task = urlSession.objectTask(for: request) { (result: Result<UserResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let userResult):
                    do {
                        let userImage = UserImage(userResult: userResult)
                        self.avatarURL = userImage.small
                        if let avatarURL = self.avatarURL {
                            print("[ProfileImageService] Successed to decode UserImage")
                            completion(.success(avatarURL))
                        } else {
                            print("[ProfileImageService] Invalid request UserImage")
                            completion(.failure(ProfileImageServiceError.invalidRequest))
                        }
                    } catch {
                        print("[ProfileImageService] Failed to fetch UserImage: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("[ProfileImageService] Error fetching UserImage: \(error)")
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }
}
