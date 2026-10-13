import Cocoa
import WebKit

class AppDelegate: NSObject, NSApplicationDelegate, WKNavigationDelegate, WKUIDelegate {
    var window: NSWindow!
    var webView: WKWebView!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let windowMask: NSWindow.StyleMask = [.titled, .closable, .miniaturizable, .resizable]
        window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1280, height: 800),
                          styleMask: windowMask,
                          backing: .buffered,
                          defer: false)
        window.center()
        window.title = "JuwishPro Admin | Mission Control"
        window.backgroundColor = NSColor(red: 11/255, green: 14/255, blue: 17/255, alpha: 1.0)
        window.titlebarAppearsTransparent = true

        let config = WKWebViewConfiguration()
        webView = WKWebView(frame: window.contentView!.bounds, configuration: config)
        webView.autoresizingMask = [.width, .height]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.customUserAgent = "JuwishProAdminMacOS/1.0.0 (Native Desktop Admin)"

        window.contentView?.addSubview(webView)
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        if let url = URL(string: "https://2026.dmillers.org/admin") {
            webView.load(URLRequest(url: url))
        }
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.cancel)
            return
        }
        if url.host == "2026.dmillers.org" || (url.host?.hasSuffix(".dmillers.org") ?? false) {
            decisionHandler(.allow)
        } else if url.scheme != "http" && url.scheme != "https" {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
        } else {
            NSWorkspace.shared.open(url)
            decisionHandler(.cancel)
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
