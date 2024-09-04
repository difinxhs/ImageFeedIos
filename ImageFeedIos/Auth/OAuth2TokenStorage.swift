import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2Token"
    
    var token: String? {
        get {
            let token = KeychainWrapper.standard.string(forKey: tokenKey)
            print("Get token: \(token ?? "nil")")
            return token
        }
        set {
            if let value = newValue {
                let success = KeychainWrapper.standard.set(value, forKey: tokenKey)
                print("Set token: \(value)")
            } else {
                let success = KeychainWrapper.standard.removeObject(forKey: tokenKey)
                print("Token removed")
            }
        }
    }
}
