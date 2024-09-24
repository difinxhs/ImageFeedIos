import Foundation
//
//enum Constants {
//    static let accessKey = "UCejgAf-_jR_PCD5Lh5LceTBacej_8df1cKELVfFjoU"
//    static let secretKey = "ZEAEoMfUlzl8UPz6q0cTUQW1tvANK2BLApcvXVgx5DM"
//    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
//    static let accessScope = "public+read_user+write_likes"
//    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
//    
//    static let baseURL = "https://unsplash.com"
//    static let usersURL = "https://api.unsplash.com/users/"
//    
//    static let profileURL = "https://api.unsplash.com/me"
//    
//    static let photoURL = "https://api.unsplash.com/photos"
//}

enum Constants {
    static let accessKey = "UCejgAf-_jR_PCD5Lh5LceTBacej_8df1cKELVfFjoU"
    static let secretKey = "ZEAEoMfUlzl8UPz6q0cTUQW1tvANK2BLApcvXVgx5DM"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"

    static let defaultBaseURL = URL(string: "https://api.unsplash.com")!
    
    static let baseURL = "https://unsplash.com"
    static let usersURL = "https://api.unsplash.com/users/"
    
    static let profileURL = "https://api.unsplash.com/me"
    
    static let photoURL = "https://api.unsplash.com/photos"
    
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
            return AuthConfiguration(accessKey: Constants.accessKey,
                                     secretKey: Constants.secretKey,
                                     redirectURI: Constants.redirectURI,
                                     accessScope: Constants.accessScope,
                                     authURLString: Constants.unsplashAuthorizeURLString,
                                     defaultBaseURL: Constants.defaultBaseURL)
        }
}
