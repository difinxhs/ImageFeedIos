import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    private let storage = OAuth2TokenStorage()
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest {
        let baseURL = URL(string: "https://unsplash.com")!
        let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"
            + "&&client_secret=\(Constants.secretKey)"
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL
        )!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(code: String, completion: @escaping (Result<String, Error>) -> Void) {
        let request = makeOAuthTokenRequest(code: code)
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self else { return }
                switch result {
                case .success(let data):
                    do {
                        let decoder = OAuthTokenJSONDecoder()
                        let token = try decoder.decode(OAuthToken.self, from: data)
                        self.storage.token = token.accessToken
                        completion(.success(token.accessToken))
                    } catch {
                        print("Failed to decode JSON: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("Error fetching OAuth token: \(error)")
                    completion(.failure(error))
                }
            }
        
        task.resume()
        }
}


