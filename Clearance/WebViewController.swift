import Cocoa
import WebKit
import UniformTypeIdentifiers

class WebViewController: NSViewController {
    private var webView: WKWebView!
    private var appearanceObservation: NSKeyValueObservation?

    override func loadView() {
        let config = WKWebViewConfiguration()

        // Allow JS on file:// to access other file:// resources — required for sql.js WASM loading
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")

        // Register saveDB handler; body implemented in Phase 3 via DownloadHandler
        config.userContentController.add(self, name: "saveDB")

        // Cmd+A in <input> fields: AppKit's Select All intercepts before WebKit can handle it.
        // This script restores expected behavior by catching the event in the capture phase.
        let cmdAScript = WKUserScript(
            source: """
            document.addEventListener('keydown', function(e) {
                if ((e.metaKey || e.ctrlKey) && e.key === 'a' &&
                    (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA')) {
                    e.target.select();
                    e.preventDefault();
                }
            }, true);
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: true
        )
        config.userContentController.addUserScript(cmdAScript)

        webView = WKWebView(frame: .zero, configuration: config)
        // Clear under-page area so there is no white flash when the OS theme changes
        webView.underPageBackgroundColor = .clear
        webView.navigationDelegate = self
        webView.uiDelegate = self

        self.view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadHTML()
        appearanceObservation = NSApp.observe(\.effectiveAppearance, options: []) { [weak self] _, _ in
            self?.syncAppearance()
        }
    }

    private func loadHTML() {
        guard let url = Bundle.main.url(forResource: "tcc_audit_app", withExtension: "html") else {
            assertionFailure("tcc_audit_app.html missing from bundle")
            return
        }
        // allowingReadAccessTo parent directory lets sql.js resolve the .wasm file alongside the HTML
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    private func syncAppearance() {
        let isDark = view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        webView.evaluateJavaScript("setSystemAppearance(\(isDark))", completionHandler: nil)
    }

    // MARK: - Menu actions (responder chain)

    @objc func openDatabase(_ sender: Any?) {
        guard let window = view.window else { return }
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = false
        if let dbType = UTType(filenameExtension: "db") {
            panel.allowedContentTypes = [dbType]
        }
        panel.beginSheetModal(for: window) { [weak self] response in
            guard response == .OK, let url = panel.url else { return }
            guard let data = try? Data(contentsOf: url) else { return }
            let b64 = data.base64EncodedString()
            let filename = url.lastPathComponent
            self?.webView.evaluateJavaScript("handleFileFromNative('\(b64)', '\(filename)')", completionHandler: nil)
        }
    }

    @objc func reloadPage(_ sender: Any?) {
        webView.reload()
    }
}

extension WebViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        guard message.name == "saveDB" else { return }
        DownloadHandler.save(message: message, in: view.window)
    }
}

extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 runOpenPanelWith parameters: WKOpenPanelParameters,
                 initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping ([URL]?) -> Void) {
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = parameters.allowsMultipleSelection
        if let dbType = UTType(filenameExtension: "db") {
            panel.allowedContentTypes = [dbType]
        }
        panel.begin { response in
            completionHandler(response == .OK ? panel.urls : nil)
        }
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        syncAppearance()
    }

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
