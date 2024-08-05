import Foundation

protocol OAuth2ServiceDelegate: AnyObject {
    func didAuthenticate(token: String)
}
