import UIKit
import WebKit

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

final class WebViewViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    weak var delegate: WebViewViewControllerDelegate?
    
    enum WebViewConstants {
        static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    }
    
    override func viewDidLoad() {
        loadAuthView()
        webView.navigationDelegate = self
    }
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //Запрос на сервер с аутентификацией
    private func loadAuthView() {
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            return
        }

        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]

        guard let url = urlComponents.url else {
            return
        }

        let request = URLRequest(url: url)
        webView.load(request)
        }
}
//MARK: WKNavigationDelegate
extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            //TODO: process code
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if
            let url = navigationAction.request.url,
            let urlComponents = URLComponents(string: url.absoluteString),
            urlComponents.path == "/oauth/authorize/native",
            let items = urlComponents.queryItems,
            let codeItem = items.first(where: {$0.name == "code"})
        {
            return codeItem.value
        } else {
            return nil
        }
    }
}
