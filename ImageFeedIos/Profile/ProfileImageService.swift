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
        let profile_image: String
    }
    
    struct UserImage {
        let profile_image: String
        
        init(userResult: UserResult) {
            self.profile_image = userResult.profile_image
        }
    }
    
    private func makeAvatarURL () -> URLRequest? {
        guard let username = username else { return nil }
        
        guard let baseURL = URL(string: "https://api.unsplash.com") else {
            assertionFailure("Failed to create URL")
            return nil
        }
        
        guard let url = URL (
            string: "/users" 
            + "/\(username)"
            + "profile_image"
            + "/small",
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
    
    
    func fetchProfileImageURL(username: String, _ completion: @escaping(Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard username == username else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        
        guard
            let request = makeAvatarURL()
        else {
            completion(.failure(ProfileImageServiceError.invalidRequest))
            return
        }
        
        let task = URLSession.shared.data(for: request) { /*[weak self]*/ result in
//            guard self != nil else { return }
                switch result {
                case .success(let data):
                    do {
                        print("decoding avatar started \(data)")
                        let decoder = JSONDecoder()
                        let userResult = try decoder.decode(UserResult.self, from: data)
                        let result = UserImage(userResult: userResult)
                        print("decode avatar JSON success \(result)")
                        self.avatarURL = result
                        completion(.success(result))
                    } catch {
                        print("Failed to decode ProfileImageJSON: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("Error fetching profile image: \(error)")
                    completion(.failure(error))
                }
            }
        
        task.resume()
    }
}
