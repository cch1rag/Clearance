# Clearance — Phases 0–3 (Milestone 1)

Archived from CLEARANCE_PROJECT_PLAN.md. Milestone 1 is complete.
Load this file only if you need to reference the original phase specs.

> **Note:** The Swift code examples in Phase 2 reflect the original spec and
> do not match the final implementation. The actual implementation differs:
> - No `@main` — explicit `main.swift` entry point is used instead
> - No `.fullSizeContentView` or `titlebarAppearsTransparent`
> - `underPageBackgroundColor = .clear` instead of `drawsBackground = false`
> - `window.isRestorable = false` added
> See `ACTION_PLAN.md` and the source files for the canonical implementation.

---

## Phase 0 — Branding & Assets

**Est. time: 1 hour | Checkpoint: icon renders at 16×16 and 512×512**

### App Icon Concept

Minimal shield glyph with a horizontal scan line through it — referencing both privacy protection and data inspection. No gradients. Two-tone: off-white stroke on dark teal fill for dark mode; reversed for light. Works at 16px and 1024px.

**Color palette:**

```
Primary (Teal):   #1A7A6E  (dark mode bg) / #E8F5F3 (light mode bg)
Accent (Amber):   #C98A4A  (pending / highlight)
Surface dark:     #0B0B0A
Surface light:    #F7F6F3
Text dark:        #E2E0D8
Text light:       #1A1A18
Granted green:    #52B56E
Denied red:       #D96060
```

### Icon Production (Xcode Asset Catalog)

Generate from a single 1024×1024 SVG using:

```bash
# After creating the SVG source icon.svg:
mkdir Clearance.iconset
for size in 16 32 64 128 256 512 1024; do
  rsvg-convert -w $size -h $size icon.svg > Clearance.iconset/icon_${size}x${size}.png
  if [ $size -ne 1024 ]; then
    rsvg-convert -w $((size*2)) -h $((size*2)) icon.svg > Clearance.iconset/icon_${size}x${size}@2x.png
  fi
done
iconutil -c icns Clearance.iconset
```

*If rsvg-convert unavailable: use macOS Preview → export at each size, or generate via SF Symbol + Sketch/Figma.*

---

## Phase 1 — Xcode Project Setup

**Est. time: 45 min | Checkpoint: blank window launches, no warnings in build log**

### Project configuration

```
Product Name:        Clearance
Bundle Identifier:   in.lucidlabs.clearance
Team:                (your Apple ID — no paid account needed for local builds)
Deployment Target:   macOS 12.0
Language:            Swift
Interface:           XIB / Programmatic (no SwiftUI — keeps it simple and fully controllable)
Architecture:        Apple Silicon + Intel (Universal)
```

### File structure to create

```
./  (project root: /Users/chiragc/Projects/Clearance)
├── Clearance.xcodeproj
├── Clearance/
│   ├── AppDelegate.swift
│   ├── MainWindowController.swift
│   ├── WebViewController.swift
│   ├── DownloadHandler.swift
│   ├── Resources/
│   │   ├── tcc_audit_app.html   ← copy from project root's Resources/ folder
│   │   └── Assets.xcassets/     ← app icon here
│   └── Info.plist
└── README.md
```

### Info.plist keys required

```xml
NSHumanReadableCopyright   → © 2026 Lucid Labs (Chirag Chopra)
CFBundleShortVersionString → 1.0.0
CFBundleVersion            → 1
LSMinimumSystemVersion     → 12.0
NSPrincipalClass           → NSApplication
LSApplicationCategoryType  → public.app-category.developer-tools
```

**Checkpoint audit:**

- [ ] `⌘B` builds clean (0 errors, 0 warnings)
- [ ] App launches and shows an empty window
- [ ] Bundle identifier is correct in signing settings

---

## Phase 2 — Swift Core: Window + WKWebView

**Est. time: 1 hour | Checkpoint: HTML loads correctly inside app window, JS works**

### AppDelegate.swift

```swift
import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var windowController: MainWindowController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        windowController = MainWindowController()
        windowController?.showWindow(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ app: NSApplication) -> Bool {
        return true
    }
}
```

### MainWindowController.swift

```swift
import Cocoa

class MainWindowController: NSWindowController {
    convenience init() {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1200, height: 760),
            styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.title = "Clearance"
        window.titlebarAppearsTransparent = true
        window.minSize = NSSize(width: 860, height: 580)
        window.center()
        self.init(window: window)
        self.contentViewController = WebViewController()
    }
}
```

### WebViewController.swift (core — full implementation)

```swift
import Cocoa
import WebKit

class WebViewController: NSViewController, WKNavigationDelegate, WKUIDelegate {
    var webView: WKWebView!

    override func loadView() {
        let config = WKWebViewConfiguration()
        // Allow local file access (needed for sql.js wasm loading)
        config.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
        webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = self
        webView.uiDelegate = self
        // Follow system appearance automatically
        webView.setValue(false, forKey: "drawsBackground")
        self.view = webView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        loadApp()
    }

    func loadApp() {
        guard let url = Bundle.main.url(forResource: "tcc_audit_app", withExtension: "html") else {
            fatalError("tcc_audit_app.html not found in bundle")
        }
        // Load with bundle base URL so WKWebView can resolve relative wasm resource
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }
}
```

**Checkpoint audit:**

- [ ] HTML drop screen appears correctly in app window
- [ ] Dark/light mode switches follow macOS System Preferences in real time
- [ ] sql.js loads (check Console for errors — `⌘⌥C` in Safari Web Inspector attached to app)
- [ ] Dragging a `.db` file onto the drop zone parses and renders the table

---

## Phase 3 — Download Handler (Native Save Panel)

**Est. time: 1 hour | Checkpoint: "Apply & Download" triggers NSSavePanel, file saves correctly, opens in TablePlus**

The HTML triggers a browser download via `<a download>`. WKWebView intercepts this with `WKDownloadDelegate`. We replace the browser download bar with macOS's native NSSavePanel.

### DownloadHandler.swift

```swift
import Cocoa
import WebKit

// Add to WebViewController: WKDownloadDelegate
// In WebViewController.viewDidLoad(), add:
//   webView.configuration.preferences.setValue(true, forKey: "allowFileAccessFromFileURLs")
//   config.websiteDataStore = .nonPersistent()   // no cookies/cache

extension WebViewController: WKDownloadDelegate {
    // Called when WKWebView decides a response should be a download
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationResponse: WKNavigationResponse,
                 decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if navigationResponse.canShowMIMEType {
            decisionHandler(.allow)
        } else {
            decisionHandler(.download)
        }
    }

    // Route the download to NSSavePanel
    func download(_ download: WKDownload,
                  decideDestinationUsing response: URLResponse,
                  suggestedFilename: String,
                  completionHandler: @escaping (URL?) -> Void) {
        let panel = NSSavePanel()
        panel.nameFieldStringValue = suggestedFilename
        panel.allowedContentTypes = [.init(filenameExtension: "db")!]
        panel.message = "Save modified TCC database"
        panel.prompt = "Save"
        panel.begin { result in
            completionHandler(result == .OK ? panel.url : nil)
        }
    }

    func downloadDidFinish(_ download: WKDownload) {
        // Optional: show a brief success notification
        let note = NSUserNotification()
        note.title = "Clearance"
        note.informativeText = "Modified database saved successfully."
        NSUserNotificationCenter.default.deliver(note)
    }
}
```

**Checkpoint audit:**

- [ ] Load a real `UserTCC.db`, make ≥1 edit, click "Apply & Download"
- [ ] NSSavePanel appears (not a browser download bar)
- [ ] Saved `.db` opens in TablePlus and reflects the edited `auth_value`
- [ ] Original `~/Desktop/UserTCC.db` is unchanged
