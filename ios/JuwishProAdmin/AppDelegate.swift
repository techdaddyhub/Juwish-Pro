import UIKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = AdminWebViewController()
        window?.rootViewController = viewController
        window?.backgroundColor = UIColor(red: 11/255, green: 14/255, blue: 17/255, alpha: 1.0)
        window?.makeKeyAndVisible()
        return true
    }
}

class AdminWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
    var webView: WKWebView!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 11/255, green: 14/255, blue: 17/255, alpha: 1.0)

        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.preferences.javaScriptCanOpenWindowsAutomatically = true

        webView = WKWebView(frame: .zero, configuration: config)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.backgroundColor = UIColor(red: 11/255, green: 14/255, blue: 17/255, alpha: 1.0)
        webView.customUserAgent = "JuwishProAdminIOS/1.0.0 (Native Mobile Admin)"

        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // Native pull-to-refresh
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor(red: 240/255, green: 185/255, blue: 11/255, alpha: 1.0)
        refreshControl.addTarget(self, action: #selector(reloadWebView), for: .valueChanged)
        webView.scrollView.refreshControl = refreshControl

        if let url = URL(string: "https://2026.dmillers.org/admin") {
            webView.load(URLRequest(url: url))
        }
    }

    @objc func reloadWebView(_ sender: UIRefreshControl) {
        webView.reload()
        sender.endRefreshing()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        if url.host == "2026.dmillers.org" || (url.host?.hasSuffix(".dmillers.org") ?? false) {
            decisionHandler(.allow)
        } else if url.scheme != "http" && url.scheme != "https" {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        } else {
            UIApplication.shared.open(url)
            decisionHandler(.cancel)
        }
    }
}
