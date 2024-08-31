import UIKit

enum AuthServiceError: Error {
    case invalidRequest
}

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    private let storage = OAuth2TokenStorage()
    
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let baseURL = URL(string: Constants.baseURL) else {
            assertionFailure("[AuthService] Failed to create URL")
            return nil
        }
        
        guard let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        ) else {
            assertionFailure("[AuthService] Failed to create URL")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        task?.cancel()
        lastCode = code
        
        guard
            let request = makeOAuthTokenRequest(code: code)
        else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<OAuthToken, Error>) in
            guard let self = self else { return }
            switch result {
            case .success(let token):
                do {
                    self.storage.token = token.accessToken
                    print("[AuthService] Successed to decode OAuthToken")
                    completion(.success(token.accessToken))
                } catch {
                    print("[AuthService] Failed to decode OAuthToken: \(error)")
                    completion(.failure(error))
                }
            case .failure(let error):
                print("[AuthService] Error fetching OAuth token: \(error)")
                completion(.failure(error))
            }
            
        }
        task.resume()
    }
}
