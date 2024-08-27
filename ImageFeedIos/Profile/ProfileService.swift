import UIKit

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    private let storage = OAuth2TokenStorage()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    
    private(set) var profile: Profile?
    
    struct ProfileResult: Codable {
        let username: String
        let first_name: String
        let last_name: String
        let bio: String
    }
    
    struct Profile {
        let username: String
        let name: String
        let bio: String
        
        init(profileResult: ProfileResult) {
            self.username = "@" + profileResult.username
            self.name = profileResult.first_name + " " + profileResult.last_name
            self.bio = profileResult.bio
        }
    }
    
     func giveMeUsername() -> String {
        guard let username = profile?.username else { return ""}
        var trueUsername: String = username
        trueUsername.removeFirst()
        return trueUsername
    }
    
    private func makeProfileURL () -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            assertionFailure("Failed to create ProfileURL")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        guard let token = storage.token else {
            assertionFailure("Failed to get ProfileToken")
            return nil
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("makeProfileURL request: \(request)")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastToken != token else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastToken = token
        
        guard
            let request = makeProfileURL()
        else {
            completion(.failure(ProfileServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { (result: Result<ProfileResult, Error>) in
            DispatchQueue.main.async {
                switch result {
                case .success(let profileResult):
                    do {
                        let result = Profile(profileResult: profileResult)
                        self.profile = result
                        print("Successed to decode Profile")
                        completion(.success(result))
                    } catch {
                        print("Failed to decode Profile: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("Error fetching Profile: \(error)")
                    completion(.failure(error))
                }
            }
        }
        
        self.task = task
        task.resume()
    }
}
