import Cocoa
import WebKit

class WebViewController: NSViewController {
    private var webView: WKWebView!

    override func loadView() {
        let config = WKWebViewConfiguration()

        // Allow JS on file:// to access other file:// resources — required for sql.js WASM loading
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        // Register saveDB handler; body implemented in Phase 3 via DownloadHandler
        config.userContentController.add(self, name: "saveDB")

        webView = WKWebView(frame: .zero, configuration: config)
        // Clear under-page area so there is no white flash when the OS theme changes
        webView.underPageBackgroundColor = .clear
        webView.navigationDelegate = self

        self.view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadHTML()
    }

    private func loadHTML() {
        guard let url = Bundle.main.url(forResource: "tcc_audit_app", withExtension: "html") else {
            assertionFailure("tcc_audit_app.html missing from bundle")
            return
        }
        // allowingReadAccessTo parent directory lets sql.js resolve the .wasm file alongside the HTML
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard message.name == "saveDB" else { return }
        DownloadHandler.save(message: message, in: view.window)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Allow only local file navigation; block any outbound network request
        let url = navigationAction.request.url
        if url == nil || url!.isFileURL || url!.absoluteString == "about:blank" {
            decisionHandler(.allow)
        } else {
            decisionHandler(.cancel)
        }
    }
}
