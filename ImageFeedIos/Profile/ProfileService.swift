import UIKit

protocol ProfileServiceProtocol {
    var profile: Profile? { get }
}

enum ProfileServiceError: Error {
    case invalidRequest
}

final class ProfileService: ProfileServiceProtocol {
    static let shared = ProfileService()
    private init() {}
    
    private let storage = OAuth2TokenStorage()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastToken: String?
    
    private(set) var profile: Profile?
    
    
    func giveMeUsername() -> String {
        guard let username = profile?.username else { return ""}
        var trueUsername: String = username
        trueUsername.removeFirst()
        return trueUsername
    }
    
    func cleanProfile() {
        profile = nil
        print("[ProfileService] cleanProfile? \(profile)")
    }
    
    private func makeProfileURL () -> URLRequest? {
        guard let url = URL(string: Constants.profileURL) else {
            assertionFailure("[ProfileService] Failed to create ProfileURL")
            return nil
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "GET"
        
        guard let token = storage.token else {
            assertionFailure("[ProfileService] Failed to get ProfileToken")
            return nil
        }
        
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        print("[ProfileService] makeProfileURL request: \(request)")
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
                        print("[ProfileService] Successed to decode Profile")
                        completion(.success(result))
                    } catch {
                        print("[ProfileService] Failed to decode Profile: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("[ProfileService] Error fetching Profile: \(error)")
                    completion(.failure(error))
                }
            }
        }
        
        self.task = task
        task.resume()
    }
}
