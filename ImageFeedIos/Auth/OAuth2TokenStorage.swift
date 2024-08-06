import Foundation

final class OAuth2TokenStorage {
    private let userDefaults = UserDefaults.standard
    private let tokenKey = "OAuth2Token"
    
    var token: String? {
        get {
            let token = userDefaults.string(forKey: tokenKey)
                        print("Get token: \(token ?? "nil")")
                        return token
        }
        set {
            userDefaults.setValue(newValue, forKey: tokenKey)
                        print("Set token: \(newValue ?? "nil")")
        }
    }
}
