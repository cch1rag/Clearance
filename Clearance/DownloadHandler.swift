import Cocoa
import WebKit

struct DownloadHandler {
    /// Receives a saveDB message from the WebView, decodes the base64 payload,
    /// and presents an NSSavePanel so the user can choose where to write the file.
    static func save(message: WKScriptMessage, in window: NSWindow?) {
        guard
            let body = message.body as? [String: Any],
            let b64  = body["data"]     as? String,
            let name = body["filename"] as? String,
            let data = Data(base64Encoded: b64)
        else {
            return
        }

        let panel = NSSavePanel()
        panel.nameFieldStringValue  = name
        panel.allowedContentTypes   = [.init(filenameExtension: "db")!]
        panel.canCreateDirectories  = true

        let write: (NSApplication.ModalResponse) -> Void = { response in
            guard response == .OK, let url = panel.url else { return }
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                let alert = NSAlert(error: error)
                alert.runModal()
            }
        }

        if let window {
            panel.beginSheetModal(for: window, completionHandler: write)
        } else {
            panel.begin(completionHandler: write)
        }
    }
}
