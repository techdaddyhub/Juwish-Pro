import UIKit
import WebKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let viewController = WebViewController()
        window?.rootViewController = viewController
        window?.backgroundColor = UIColor(red: 11/255, green: 14/255, blue: 17/255, alpha: 1.0)
        window?.makeKeyAndVisible()
        return true
    }
}

class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {
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
        webView.customUserAgent = "JuwishProIOS/1.0.0 (Native Mobile App)"

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

        if let url = URL(string: "https://2026.dmillers.org") {
            webView.load(URLRequest(url: url))
        }
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loadOfflineScreen(target: "https://2026.dmillers.org")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loadOfflineScreen(target: "https://2026.dmillers.org")
    }

    func loadOfflineScreen(target: String) {
        let html = """
        <!DOCTYPE html>
        <html>
        <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no">
        <style>
          * { box-sizing: border-box; }
          body {
            margin: 0; padding: 24px;
            background-color: #0B0E11;
            color: #EAECEF;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            display: flex; flex-direction: column; align-items: center; justify-content: center;
            height: 100vh; text-align: center;
          }
          .icon-box {
            position: relative; width: 110px; height: 110px; margin-bottom: 24px;
            display: flex; align-items: center; justify-content: center;
          }
          .coin-circle {
            width: 96px; height: 96px; border-radius: 50%;
            background: radial-gradient(circle at 35% 30%, #FFF5C0 0%, #F0B90B 50%, #734F00 100%);
            display: flex; align-items: center; justify-content: center;
            box-shadow: 0 10px 24px rgba(0,0,0,0.6), 0 0 20px rgba(240,185,11,0.25);
          }
          .coin-inner {
            width: 78px; height: 78px; border-radius: 50%;
            background: radial-gradient(circle, #1B1F27 0%, #0B0E11 100%);
            display: flex; align-items: center; justify-content: center;
            border: 2px solid #F0B90B;
          }
          .star { font-size: 38px; color: #F0B90B; line-height: 1; }
          .badge {
            position: absolute; right: 0; bottom: 0; width: 40px; height: 40px;
            background: #1E2329; border: 2px solid #F6465D; border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            box-shadow: 0 4px 10px rgba(0,0,0,0.6);
          }
          .badge svg { width: 22px; height: 22px; fill: #F6465D; }
          h1 { font-size: 22px; margin: 0 0 10px; font-weight: 700; color: #EAECEF; }
          p { font-size: 14px; margin: 0 0 28px; color: #848E9C; line-height: 1.5; max-width: 320px; }
          .retry-btn {
            background: #F0B90B; color: #0B0E11; border: none; outline: none;
            padding: 13px 34px; border-radius: 24px; font-weight: 700; font-size: 15px;
            cursor: pointer; text-decoration: none; display: inline-block;
          }
        </style>
        </head>
        <body>
          <div class="icon-box">
            <div class="coin-circle">
              <div class="coin-inner">
                <span class="star">&#x2721;</span>
              </div>
            </div>
            <div class="badge">
              <svg viewBox="0 0 24 24"><path d="M22.99,9C20.89,7.32 16.99,5 12,5C10.74,5 9.54,5.18 8.44,5.49L10.36,7.41C10.89,7.35 11.43,7.31 12,7.31C16.02,7.31 19.34,9.08 20.91,10.36L22.99,9ZM1,3.27L3.28,5.55C1.86,6.67 0.73,7.9 0.01,9L12,24L17.27,17.41L20.73,20.87L22,19.6L2.27,2L1,3.27ZM12,19.37L4.35,9.81C5.69,8.77 7.27,8.04 8.99,7.66L15.65,14.32L12,19.37ZM15.54,12.59L17.51,14.56L18.49,13.33C17.58,12.53 16.59,11.96 15.54,12.59Z"/></svg>
            </div>
          </div>
          <h1>Connection Offline</h1>
          <p>Network connection is currently unavailable. Please verify your internet connection and tap retry.</p>
          <a class="retry-btn" href="\(target)">Retry Connection</a>
        </body>
        </html>
        """
        webView.loadHTMLString(html, baseURL: nil)
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

