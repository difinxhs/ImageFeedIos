import UIKit
import WebKit

final class WebViewViewController: UIViewController {
    @IBOutlet weak var webView: WKWebView!
    
    @IBAction func backButtonDidTap(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
