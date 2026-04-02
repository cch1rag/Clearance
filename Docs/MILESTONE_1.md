# Milestone 1: Foundation

Goal: App launches, WebView loads the existing HTML app, drag-and-drop parses
a .db file, and the download handler routes saves through a native NSSavePanel.

Prerequisite: None. This is the starting point.

---

## Phases

### Phase 0 — Branding & Assets
Branch: `feature/0-branding`

Tasks:
- Design icon: minimal shield glyph with a horizontal scan line through it,
  two-tone teal/off-white, no gradients. Must read clearly at 16px and 1024px.
- Generate all required sizes from a single 1024x1024 SVG
- Add to Xcode Assets.xcassets

Color palette:
  Primary Teal (dark bg):  #1A7A6E
  Primary Teal (light bg): #E8F5F3
  Accent Amber:            #C98A4A
  Surface dark:            #0B0B0A
  Surface light:           #F7F6F3
  Text dark:               #E2E0D8
  Text light:              #1A1A18
  Granted green:           #52B56E
  Denied red:              #D96060

Icon generation:
  Sizes required: 16, 32, 64, 128, 256, 512, 1024
  Plus @2x for all sizes except 1024
  Output: Clearance.iconset/ then run: iconutil -c icns Clearance.iconset

  If rsvg-convert is unavailable, use macOS Preview to export at each size
  manually. Do not install Homebrew or any external tool to accomplish this.

Audit checklist:
- [x] Icon renders cleanly at 16x16 with no aliasing artifacts
- [x] Icon renders cleanly at 512x512
- [x] All required .iconset sizes present
- [x] .icns file generated and added to Assets.xcassets

---

### Phase 1 — Xcode Project Setup
Branch: feature/1-xcode-setup`

Config:
  Product Name:       Clearance
  Bundle ID:          com.lucidlabs.clearance
  Deployment Target:  macOS 12.0
  Language:           Swift
  Interface:          Programmatic (no SwiftUI, no XIB)
  Architecture:       Universal (Apple Silicon + Intel)

File structure to create:
  ./  (project root — this is /Users/chiragc/Projects/Clearance, not a subfolder)
  ├── Clearance.xcodeproj
  ├── Clearance/              ← Xcode target source folder (a subfolder of project root)
  │   ├── AppDelegate.swift
  │   ├── MainWindowController.swift
  │   ├── WebViewController.swift
  │   ├── DownloadHandler.swift
  │   ├── Resources/
  │   │   ├── tcc_audit_app.html   ← copy from Resources/tcc_audit_app.html (project root)
  │   │   └── Assets.xcassets/
  │   └── Info.plist
  └── README.md

Required Info.plist keys:
  NSHumanReadableCopyright    → © 2026 Chirag Chopra
  CFBundleShortVersionString  → 1.0.0
  CFBundleVersion             → 1
  LSMinimumSystemVersion      → 12.0
  NSPrincipalClass            → NSApplication
  LSApplicationCategoryType   → public.app-category.developer-tools

Audit checklist:
- [x] Cmd+B builds clean (0 errors, 0 warnings)
- [x] App launches and shows an empty window
- [x] Bundle ID reads correctly in Signing & Capabilities
- [x] Universal build target confirmed in Build Settings

---

### Phase 2 — Swift Window + WKWebView
Branch: feature/2-webview`

Note: tcc_audit_app.html already exists at Resources/tcc_audit_app.html in the
project root. Phase 1 copies it into Clearance/Resources/ (the Xcode target
source folder). This phase only requires the Swift wrapper to load it correctly.
Do not modify the HTML.

Implement:
- AppDelegate.swift: instantiate MainWindowController on launch, quit on
  last window close
- MainWindowController.swift: 1200x760 window, min size 860x580, full size
  content view, transparent titlebar, centered on launch
- WebViewController.swift: WKWebView with local file access enabled,
  drawsBackground set to false for seamless theme transparency,
  loads tcc_audit_app.html from bundle using loadFileURL with
  allowingReadAccessTo set to the parent directory (required for sql.js
  wasm file resolution)

Also register the saveDB script message handler in WebViewController
(see Phase 3 — the handler needs to be in place before the HTML loads):
  config.userContentController.add(self, name: "saveDB")

Key config:
  allowFileAccessFromFileURLs = true
  Load via: webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())

Audit checklist:
- [x] Drop screen appears correctly inside the app window
- [x] Dark/light mode switches follow System Preferences in real time, no reload
- [x] sql.js loads without console errors (attach Safari Web Inspector:
      Safari > Develop > [your Mac] > Clearance)
- [x] Dragging a real .db file onto the drop zone parses and renders the table
- [x] No JS errors in console related to the saveDB handler being missing

---

### Phase 3 — Download Handler
Branch: feature/3-download-handler`

The HTML's applyAndDownload() generates a Uint8Array blob in-page using sql.js.
WKDownloadDelegate cannot intercept blob URL clicks — they never become
navigation events in WKWebView. Use WKScriptMessageHandler instead.

Swift side (WebViewController.swift + DownloadHandler.swift):
- WebViewController already registers the "saveDB" handler (done in Phase 2)
- Conform WebViewController to WKScriptMessageHandler
- In userContentController(_:didReceive:):
  - Extract "data" (base64 string) and "filename" from the message body
  - Decode base64 to Data
  - Open NSSavePanel filtered to .db, pre-filled with the filename
  - On confirm, write Data to the chosen URL
  - Post a success toast back via evaluateJavaScript if desired

HTML side — modify applyAndDownload() in tcc_audit_app.html:
  After generating `data` (Uint8Array from cloned.export()), replace the
  existing <a> click block with:

    const fname = dbFilename.replace(/\.db$/i, '') + '_modified.db';
    if (window.webkit?.messageHandlers?.saveDB) {
      // Native path: hand off to Swift NSSavePanel
      const b64 = btoa(String.fromCharCode(...data));
      window.webkit.messageHandlers.saveDB.postMessage({ data: b64, filename: fname });
    } else {
      // Browser fallback: keeps testing outside the app working
      const blob = new Blob([data], { type: 'application/octet-stream' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url; a.download = fname;
      document.body.appendChild(a); a.click(); document.body.removeChild(a);
      setTimeout(() => URL.revokeObjectURL(url), 2000);
    }

Also add handleFileFromNative() to the HTML for use by Phase 5 (Cmd+O):
  This function will be called by Swift via evaluateJavaScript when the user
  picks a file from the native file picker.

    function handleFileFromNative(base64Data, filename) {
      const binary = atob(base64Data);
      const bytes = new Uint8Array(binary.length);
      for (let i = 0; i < binary.length; i++) bytes[i] = binary.charCodeAt(i);
      const file = new File([bytes], filename, { type: 'application/octet-stream' });
      handleFile(file);
    }

Audit checklist:
- [x] Load a real UserTCC.db, make at least one edit, click "Apply & Download"
- [x] NSSavePanel appears (not a browser download bar)
- [x] Saved .db opens in TablePlus and reflects the edited auth_value
- [x] Original ~/Desktop/UserTCC.db is unchanged after the operation
- [x] Tested in browser directly (open HTML in Safari): fallback <a> download works

---

## Milestone 1 Gate

All four phase audits must pass before this milestone is marked complete.
Merge all phase branches to main via individual PRs. Milestone is done when
the last PR is merged and the app passes a full end-to-end test:

  Open app → drag DB onto drop zone → edit a cell → click Apply & Download
  → NSSavePanel appears → save file → open saved file in TablePlus
  → confirm auth_value reflects the edit → confirm original file unchanged

Status: [ ] Complete
