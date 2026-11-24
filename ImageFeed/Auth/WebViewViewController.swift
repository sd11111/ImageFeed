import UIKit
import WebKit

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    
    @IBOutlet private var webView: WKWebView!

    @IBOutlet private var progressView: UIProgressView!
    weak var delegate: WebViewViewControllerDelegate?
    var presenter: WebViewPresenterProtocol?
    private var estimatedProgressObservation: NSKeyValueObservation?
    func load(request: URLRequest) {
        webView.load(request)
    }

    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }

    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.accessibilityIdentifier = "UnsplashWebView"
        webView.navigationDelegate = self

        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
            options: [.new]
        ) { [weak self] _, _ in
            DispatchQueue.main.async {
                guard let self else { return }
                self.presenter?.didUpdateProgressValue(self.webView.estimatedProgress)
            }
        }

        presenter?.viewDidLoad()
    }
}

extension WebViewViewController: WKNavigationDelegate {
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
        } else {
            decisionHandler(.allow)
        }
    }
    private func code(from navigationAction: WKNavigationAction) -> String? {
        if let url = navigationAction.request.url {
            return presenter?.code(from: url)
        }
        return nil
    }
}

protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
}
