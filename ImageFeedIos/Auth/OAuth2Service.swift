import UIKit

final class OAuth2Service {
    static let shared = OAuth2Service()
    private init() {}
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
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
        
        let task = URLSession.shared.data(for: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                        let token = responseBody.accessToken
                        OAuth2TokenStorage().token = token
                        completion(.success(token))
                    } catch {
                        print("Failed to decode JSON: \(error)")
                        completion(.failure(error))
                    }
                case .failure(let error):
                    print("Error fetching OAuth token: \(error)")
                    completion(.failure(error))
                }
            }
        }
        
        task.resume()
    }

}

struct OAuthTokenResponseBody: Decodable {
    let accessToken: String
    let tokenType: String
    let scope: String
    let createdAt: Int

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case tokenType = "token_type"
        case scope
        case createdAt = "created_at"
    }
}
