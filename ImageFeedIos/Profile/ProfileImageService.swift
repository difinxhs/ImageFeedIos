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
        guard let username = username else { return nil }
        
        guard let url = URL(string: "https://api.unsplash.com/users/\(username)") else {
            assertionFailure("Failed to create ProfileImageURL")
            return nil
        }
        print("makeAvatarURL url: \(url)")
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        guard let token = storage.token else {
            assertionFailure("Failed to get ProfileImageToken")
            return nil
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("makeAvatarURL request: \(request)")
        return request
    }
    
    func fetchProfileImageURL(username: String, _ completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        print("fetchProfileImageURL username: \(username)")
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
                                print("Successed to decode UserImage")
                                completion(.success(avatarURL))
                            } else {
                                print("Invalid request UserImage")
                                completion(.failure(ProfileImageServiceError.invalidRequest))
                            }
                        } catch {
                            print("Failed to fetch UserImage: \(error)")
                            completion(.failure(error))
                        }
                    case .failure(let error):
                        print("Error fetching UserImage: \(error)")
                        completion(.failure(error))
                    }
                }
            }
        
        task.resume()
    }
}
