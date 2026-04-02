# Clearance — Project Execution Plan

**macOS Privacy Permission Manager**
*Built by Lucid Labs · Chirag Chopra*

---

## App Identity

|               |                                                                                                                       |
| ------------- | --------------------------------------------------------------------------------------------------------------------- |
| **Name**      | Clearance                                                                                                             |
| **Tagline**   | Full visibility into what your Mac apps can access.                                                                   |
| **One-liner** | A native macOS tool to audit, edit, and understand app privacy permissions. 100% local — no data leaves your machine. |
| **Category**  | Developer Tools / Privacy & Security                                                                                  |
| **License**   | MIT                                                                                                                   |
| **Min macOS** | 12 Monterey                                                                                                           |
| **Arch**      | Universal (Apple Silicon + Intel)                                                                                     |

**Why "Clearance":** Security clearance = who has access to what. It's a double meaning (clearing permissions), short enough to remember, not taken on GitHub as a macOS utility, and SEO-friendly in the privacy tools space.

---

## Deliverables Checklist

- [ ] Swift macOS app (WKWebView wrapper)
- [ ] Embedded HTML viewer/editor (dark + light theme, auto-follows system)
- [ ] App icon (all required sizes)
- [ ] GitHub repository, fully structured
- [ ] README (SEO-optimised, with screenshot, install badge, usage GIF)
- [ ] CONTRIBUTING.md
- [ ] CODE_OF_CONDUCT.md
- [ ] SECURITY.md
- [ ] LICENSE (MIT)
- [ ] .gitignore (Xcode + macOS)
- [ ] GitHub Release v1.0.0 with universal binary `.zip`
- [ ] GitHub Topics tags (for discoverability)
- [ ] App menu bar: File, Help, About
- [ ] About panel with version, author, GitHub link

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

---

## Phase 4 — HTML Layer: Light Theme + Privacy Copy

**Est. time: 45 min | Checkpoint: both themes match spec, privacy banner visible on drop screen**

### Light theme additions to `tcc_audit_app.html`

Add `@media (prefers-color-scheme: light)` block to the existing `:root` styles:

```css
@media (prefers-color-scheme: light) {
  :root {
    --bg: #F7F6F3; --sf: #FFFFFF; --sf2: #F0EEE9; --sf3: #E8E5DF;
    --bd: rgba(0,0,0,0.07); --bd2: rgba(0,0,0,0.11); --bd3: rgba(0,0,0,0.16);
    --tx: #1A1A18; --tx2: #6B6B68; --tx3: #9B9B98; --tx4: #C8C6C0;
    --grn: #2D8A4E; --grn-bg: rgba(45,138,78,0.09); --grn-bd: rgba(45,138,78,0.22);
    --red: #B84040; --red-bg: rgba(184,64,64,0.09); --red-bd: rgba(184,64,64,0.22);
    --amb: #9E6428; --amb-bg: rgba(158,100,40,0.09); --amb-bd: rgba(158,100,40,0.25);
    --blue: #2E6DA4; --blue-bg: rgba(46,109,164,0.09);
  }
}
```

### Privacy banner on drop screen

Add directly above `<p class="drop-notice">`:

```html
<div class="privacy-badge">
  <span class="priv-icon">⬡</span>
  100% local  ·  no data leaves your Mac
</div>
```

```css
.privacy-badge {
  font-size: 11px; color: var(--grn); background: var(--grn-bg);
  border: 1px solid var(--grn-bd); border-radius: 20px;
  padding: 5px 14px; margin-bottom: 20px;
  display: flex; align-items: center; gap: 6px;
}
.priv-icon { font-size: 13px; }
```

**Checkpoint audit:**

- [ ] Switch System Preferences → Light — app switches without reload
- [ ] Switch to Dark — reverts cleanly
- [ ] Privacy badge visible on drop screen in both themes
- [ ] No hard-coded color hex values remain in the HTML outside `:root` blocks

---

## Phase 5 — App Menu & About Panel

**Est. time: 30 min | Checkpoint: all menu items functional, About shows correct version**

### Menu items to implement

```
Clearance
  ├── About Clearance        → NSPanel with version, author, GitHub link
  └── Quit Clearance  ⌘Q

File
  ├── Open Database…  ⌘O     → NSOpenPanel filtered to .db
  └── Reload          ⌘R     → webView.reload()

Help
  └── View on GitHub         → opens github.com/lucidlabsco/clearance
```

### About panel content

```
Clearance  v1.0.0
A macOS privacy permission manager.
Built by Chirag Chopra / Lucid Labs

100% local — no data leaves your Mac.

github.com/lucidlabsco/clearance
MIT License
```

**Checkpoint audit:**

- [ ] `⌘O` opens a file picker filtered to `.db` files
- [ ] Selected file loads into the webView (via JS injection: `handleFileFromNative(path)`)
- [ ] `⌘R` reloads cleanly, drop screen returns
- [ ] About window shows correct version number pulled from `Bundle.main.infoDictionary`

---

*Phases 6–10 archived → [Docs/archive/phases_6_10.md](../archive/phases_6_10.md). Load when starting Milestone 3.*

